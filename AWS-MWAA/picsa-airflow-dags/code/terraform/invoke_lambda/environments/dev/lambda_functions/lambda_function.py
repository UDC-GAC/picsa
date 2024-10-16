""" Lambda parameters

Attributes:
    bucket (boto3.client): Boto3 S3 client
    s3 (string): Destination S3 bucket
"""
import json
import os
import boto3


s3 = boto3.client('s3')
bucket = os.environ['s3_bucket']


def lambda_handler():
    """ Lambda payload
    
    Args:
        event (): 
        context (): 
    """
    cust_address = {}
    cust_address['name'] = 'Joe Dann'
    cust_address['Street'] = 'Down Town'
    cust_address['City'] = 'Alaska'
    cust_address['customerId'] = 'CID-11111'
    file_name = 'CusJoe697' + '.json'


    upload_byte_stream = bytes(json.dumps(cust_address).encode('UTF-8'))
    s3.put_object(Bucket=bucket, Key=file_name, Body=upload_byte_stream)


    print('Added Completec')

