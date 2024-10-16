# We'll start by importing the DAG object
from airflow import DAG
# We need to import the operators used in our tasks
from airflow.operators.python import PythonOperator

import pandas as pd
import pendulum
import psycopg2
import os
import boto3
from py_dotenv import read_dotenv


# get dag directory path
dag_path = os.getcwd()
raw_data_path = "".join([dag_path, "/raw_data/"])
processed_data_path = "".join([dag_path, "/processed_data/"])
processed_file_path = "".join([processed_data_path, "processed_data.csv"])

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


def transform_data():
    if not os.path.exists(raw_data_path):
        os.makedirs(raw_data_path)
    for file in s3client.list_objects_v2(Bucket=bucket_name, 
                                         Prefix='etl_s3_to_rds_pandas/')['Contents']:
        try:
            filename = file['Key'].rsplit('/', 1)[1]
            if filename == "":
                    continue
        except IndexError:
            filename = file['Key']
        s3client.download_file(Bucket=bucket_name, 
                               Key=file['Key'],
                               Filename="".join([raw_data_path, filename]))

    booking = pd.read_csv(f"{raw_data_path}booking.csv", low_memory=False)
    client = pd.read_csv(f"{raw_data_path}client.csv", low_memory=False)
    hotel = pd.read_csv(f"{raw_data_path}hotel.csv", low_memory=False)

    # merge booking with client
    data = pd.merge(booking, client, on='client_id')
    data.rename(columns={'name': 'client_name', 'type': 'client_type'}, inplace=True)

    # merge booking, client & hotel
    data = pd.merge(data, hotel, on='hotel_id')
    data.rename(columns={'name': 'hotel_name'}, inplace=True)

    # Convert client age to integer
    data = data.astype({"age": 'int'})

    # make date format consistent
    data.booking_date = pd.to_datetime(data.booking_date, format="mixed")

    # make all cost in GBP currency
    data.loc[data.currency == 'EUR', ['booking_cost']] = data.booking_cost * 0.8
    data.currency.replace("EUR", "GBP", inplace=True)

    # remove unnecessary columns
    data = data.drop('address', axis='columns')

    if not os.path.exists(processed_data_path):
        os.makedirs(processed_data_path)

    # load processed data
    data.to_csv(processed_file_path, index=False)

    s3client.upload_file(Bucket=bucket_name,
                         Key="".join(["etl_s3_to_rds_pandas/processed_data/", "processed_data.csv"]),
                         Filename=processed_file_path)


def load_data():
    connection_string = "dbname={} host={} user={} password={} port={}".format(
                        database_name, database_endpoint, database_user, database_password, database_port)

    s3client.download_file(Bucket=bucket_name,
                           Key="".join(["etl_s3_to_rds_pandas/processed_data/", "processed_data.csv"]),
                           Filename=processed_file_path)

    with psycopg2.connect(connection_string) as connection:
        with connection.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS booking_record (
                    client_id INTEGER NOT NULL,
                    booking_date TEXT NOT NULL,
                    room_type TEXT NOT NULL,
                    hotel_id INTEGER NOT NULL,
                    booking_cost NUMERIC,
                    currency TEXT,
                    age INTEGER,
                    client_name TEXT,
                    client_type TEXT,
                    hotel_name TEXT
                );
            """)

            with open(processed_file_path, "r") as file:
                next(file) # Avoid write the CSV headers
                cursor.copy_from(file, 'booking_record', sep=",")

            connection.commit()


# initializing the default arguments that we'll pass to our DAG
default_args = {
    'owner': 'Torusware',
    'start_date': pendulum.today('UTC').add(days=-5),
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False
}

ingestion_dag = DAG(
    'booking_ingestion_pandas',
    default_args=default_args,
    description='Aggregates booking records for data analysis using Pandas',
    schedule="0 0 * * 1-5",
    catchup=False
)

task_1 = PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    dag=ingestion_dag,
)

task_2 = PythonOperator(
    task_id='load_data',
    python_callable=load_data,
    dag=ingestion_dag,
)


task_1 >> task_2
