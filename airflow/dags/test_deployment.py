from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

# This is a test DAG to verify GitHub Actions deployment

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
}

with DAG(
    'test_deployment',
    default_args=default_args,
    description='Test DAG for verifying deployment workflow',
    schedule_interval='@daily',
    catchup=False,
) as dag:

    test_task = BashOperator(
        task_id='test_task',
        bash_command='echo "This DAG was deployed via GitHub Actions!"',
    )
