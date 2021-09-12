# Creating An ETL Pipeline Using Apache Airflow 

#### Please note, this file was created via a virtual machine development environment, so it is unlikely to run in any localized environments upon download. A description of the pipeline's functionality will follow. 

## Goal: To gain learning experience with Apache Airflow by constructing and implementing a simple ordering of tasks in Airflow. 

## Environment Set up

Although Apache Airflow provides a streamlined user experience regarding the scheduling of automated pipeline tasks, the module's size and complexity makes it difficult to run in a local environment. Therefore, for anyone seeking to run Apache Airflow, either for personal or professional use, it is highly recommended that a user create a remote environment using a VM like Docker or Oracle's VM (used to run this project). The VM I used was provided as part of a course I took, Introduction to Apache Airflow by Marc Lamberti on Udemy.

## DAG 

Apache Airflow groups and prioritizes tasks as units known as directed acryllic graphs (DAGs). DAGs can be run sequentially or concurrently. When DAGs are executed concurrently, they follow an order of execution delegated by nine user-defined trigger rules. DAGs can be created, instantiated and testedin any virtual environment that supports Python. DAGs and their associated tasks can be tested using the command line interface (CLI) in any IDE or OS terminal. 
