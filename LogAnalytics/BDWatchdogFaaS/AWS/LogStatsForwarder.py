import json
import boto3
import urllib3
from datetime import datetime as dt
import os

def send2powerbi(message, url):
	http = urllib3.PoolManager()
	headers = {
		"Content-Type": "application/json"
	}
	resp = http.request(
	    "POST",
	    url,
	    headers=headers,
	    body=json.dumps(message).encode('utf-8')
	)
	
def avgMetric(data, metric):
    if len(data)>0:
        return float(sum(i[metric] for i in data)/len(data))
    return 0
    
def lambda_handler(event, context):
    stats = {}
    powerbiUrl = os.environ['PowerBIUrl']
    tableName = os.environ['LambdaLogsTable']

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(tableName)
    response = table.scan()
    data = response['Items']
 
    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])

    succeses = list(filter(lambda x: x['result']=="Success",data))
    failures = list(filter(lambda x: x['result']=="Failure",data))
    
    stats['totalInvocations'] = len(data)
    stats['totalSuccesses'] = len(succeses)
    stats['totalFailures'] = len(failures)
    stats['percentageSuccess'] = (len(succeses)/len(data))*100
    stats['avgDuration'] = avgMetric(data, 'duration')
    stats['avgSuccessDuration'] = avgMetric(succeses, 'duration')
    stats['avgFailureDuration'] = avgMetric(failures, 'duration')
    stats['avgMemory'] = avgMetric(data, 'memoryUsed')
    stats['avgSuccessMemory'] = avgMetric(succeses, 'memoryUsed')
    stats['avgFailureMemory'] = avgMetric(failures, 'memoryUsed')
    stats['avgMemorySize'] = avgMetric(data, 'memorySize')
    stats['avgSuccessMemorySize'] = avgMetric(succeses, 'memorySize')
    stats['avgFailureMemorySize'] = avgMetric(failures, 'memorySize')  
    stats['timestamp'] = dt.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ")

    send2powerbi(stats, powerbiUrl)
    return {
        'statusCode': 200,
        'body': json.dumps('')
    }
