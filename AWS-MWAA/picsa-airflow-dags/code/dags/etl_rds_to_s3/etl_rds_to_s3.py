# We'll start by importing the DAG object
from airflow import DAG
# We need to import the operators used in our tasks
from airflow.operators.python import PythonOperator

import pandas as pd
import csv
import pendulum
import psycopg2
import os
import boto3
from py_dotenv import read_dotenv


# get dag directory path
dag_path = os.getcwd()
extracted_data_file = "".join([dag_path, "/data/exported_data_from_booking_record.csv"])

# Boto3 S3 client
s3 = boto3.resource('s3')
s3client = boto3.client('s3')

dotenv_path = os.path.join(os.path.dirname(__file__), '.env')
read_dotenv(dotenv_path)

bucket_name = os.getenv('BUCKET_NAME')
database_name = os.getenv('DATABASE_NAME')
database_endpoint = os.getenv('DATABASE_ENDPOINT')
database_user = os.getenv('DATABASE_USER')
database_password = os.getenv('DATABASE_PASSWORD')
database_port = os.getenv('DATABASE_PORT')


def extract_data():
    connection_string = "dbname={} host={} user={} password={} port={}".format(
                        database_name, database_endpoint, database_user, database_password, database_port)

    with psycopg2.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT * FROM booking_record;
                """)
            data = cursor.fetchall()

    with open(extracted_data_file, "w", newline="") as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow([i[0] for i in cursor.description])
        csv_writer.writerows(cursor)

    extracted_data_path = extracted_data_file.rsplit("/", 1)[0]
    if not os.path.exists(extracted_data_path):
        os.makedirs(extracted_data_path)

    s3client.upload_file(Bucket=bucket_name,
                         Key="".join(["etl_rds_to_s3/processed_data/", "processed_data.csv"]),
                         Filename=extracted_data_file)

# initializing the default arguments that we'll pass to our DAG
default_args = {
    'owner': 'Torusware',
    'start_date': pendulum.today('UTC').add(days=-5),
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False
}

ingestion_dag = DAG(
    'extract_data_from_rds_to_s3',
    default_args=default_args,
    description='Aggregates booking records for data analysis',
    schedule="0 0 * * 1-5",
    catchup=False
)

task_1 = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=ingestion_dag,
)

task_1
