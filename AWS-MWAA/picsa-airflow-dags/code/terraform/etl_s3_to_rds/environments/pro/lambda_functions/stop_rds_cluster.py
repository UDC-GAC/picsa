import boto3
from os import environ

DBClusterIdentifier=environ.get('cluster_identifier')

def lambda_handler(event, context):
    
    boto3.client('rds').stop_db_cluster(DBClusterIdentifier=DBClusterIdentifier)
    print ('Stopping your Aurora Cluster (' + str(DBClusterIdentifier) + ')...')
