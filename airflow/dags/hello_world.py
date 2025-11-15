"""
Hello World DAG - A simple example DAG for Apache Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'hello_world',
    default_args=default_args,
    description='A simple hello world DAG',
    schedule=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example', 'hello_world'],
)

# Python function for the PythonOperator
def print_hello():
    """Print hello message with timestamp"""
    print("Hello World from Airflow!")
    print(f"Current time: {datetime.now()}")
    return "Hello task completed successfully"

# Task 1: Print hello using BashOperator
hello_bash = BashOperator(
    task_id='hello_bash',
    bash_command='echo "Hello from Bash!"',
    dag=dag,
)

# Task 2: Print hello using PythonOperator
hello_python = PythonOperator(
    task_id='hello_python',
    python_callable=print_hello,
    dag=dag,
)

# Task 3: Print completion message
complete = BashOperator(
    task_id='complete',
    bash_command='echo "Hello World DAG completed at $(date)"',
    dag=dag,
)

# Define task dependencies
hello_bash >> hello_python >> complete
