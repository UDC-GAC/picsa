"""Summary

Attributes:
    bash_command (TYPE): Description
    dag (TYPE): Description
    default_args (TYPE): Description
    show_data (TYPE): Description
    t1 (TYPE): Description
"""

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
from airflow.utils.dates import days_ago
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.hooks.lambda_function import LambdaHook
import boto3, json


# Following are defaults which can be overridden later on
default_args = {
    'owner': 'torusware',
    'depends_on_past': False,
    'email': ['david.fraga@torusware.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}


def lambda1(ds, **kwargs):
    """Summary
    
    Args:
        ds (TYPE): Description
        **kwargs: Description
    """
    hook = LambdaHook('airflowLambdaToS3',
                      region_name='ap-southeast-1',
                      client_type='lambda',
                      config=None
                      )
    response_1 = hook.invoke_lambda(function_name='airflowLambdaToS3',
                                    payload='null')
    print('Response---> ' , response_1)


dag = DAG(dag_id='lambdaflw',
          default_args=default_args,
          start_date=days_ago(1),
          schedule_interval=timedelta(days=1))


# t1, t2, t3 and t4 are examples of tasks created using operators
t1 = PythonOperator(
    task_id="lambda1",
    python_callable=lambda1,
    provide_context=True
)


# Templated command with macros
bash_command = """
        {% for task in dag.task_ids %}
            echo "{{ task }}"
            echo "{{ ti.xcom_pull(task) }}"
        {% endfor %}
    """
# Show result
show_data = BashOperator(
    task_id='show_result',
    bash_command=bash_command,
    dag=dag
)


t1 >> show_data
