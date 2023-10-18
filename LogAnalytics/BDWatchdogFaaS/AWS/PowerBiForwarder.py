import json
import gzip
import base64
from datetime import datetime
import urllib3
import uuid
import boto3
from decimal import Decimal
import os

POWERBI_URL = "https://api.powerbi.com/beta/a3d3d170-ee12-43b9-9415-e4297aff54a0/datasets/2f066629-1ca3-43e0-8716-33db48df6a6e/rows?experience=power-bi&key=dampyMVD10fNuApB36QXuGlfLbGn6l6JFwz%2B%2BltXtujNUYhjbrXN6ZGMxq0P9nPG%2FjYSdwlaQPhBmyFnZ4NJdg%3D%3D"

def uncompress_payload(cw_data):
    compressed_payload = base64.b64decode(cw_data)
    uncompressed_payload = gzip.decompress(compressed_payload)
    payload = json.loads(uncompressed_payload)
    return payload

def parse_report(str, d):
	words = str.split()
	d["requestId"] = words[2]
	d["duration"] = float(words[4])
	d["billedDuration"] = float(words[8])
	d["memorySize"] = float(words[12])
	d["memoryUsed"] = float(words[17])
	return d

def parse_error(str):
	lines = str.split("\n")
	words = lines[0].split()
	return {
		"errorType": words[1][:-1],
		"errorMessage" : " ".join(words[2:])
	}

def create_common_log(report):
	return {
		"id": report["id"],
		"result": report["result"],
		"duration": float(report["duration"]),
		"timestamp": report["timestamp"],
		"operationId": report["requestId"],
		"source": "AWS"
	}

	
def send_report_powerbi(report, url):
	http = urllib3.PoolManager()
	headers = {
		"Content-Type": "application/json"
	}
	resp = http.request(
	    "POST",
	    url,
	    headers=headers,
	    body=json.dumps(report).encode("utf-8")
	)
	

def lambda_handler(event, context):
	cw_data = event["awslogs"]["data"]
	payload = uncompress_payload(cw_data)
	log_events = payload["logEvents"]
	dynamodb = boto3.resource("dynamodb")
	table = dynamodb.Table(os.environ["LambdaLogsTable"])
	powerbi_url = os.environ["PowerBIStreamLogsUrl"]
	
	reportReceived = False
	id = uuid.uuid4().hex
	report = {
		"id": id,
		"result": "Success",
		"source": "AWS"
	}
	
	for log_event in log_events:
		timestamp = datetime.fromtimestamp(log_event["timestamp"] / 1000.0).strftime("%Y-%m-%d %H:%M:%S.%f")
		report["timestamp"] = timestamp
		message = log_event["message"]
		if message.startswith("[ERROR]"):
			err = parse_error(message)
			err["timestamp"] = timestamp
			report["result"] = "Failure"
		if message.startswith("REPORT"):
			reportReceived = True
			report = parse_report(message, report)

	if reportReceived:
		common_log = create_common_log(report)
		send_report_powerbi(report, powerbi_url)
		item = json.loads(json.dumps(report), parse_float=Decimal)
		response = table.put_item(
			Item=item
		)
	else:
		print("No reports found...")
		
	return {
		"statusCode": 200,
		"body": json.dumps("Lambda logs forwarded correctly!")
	}
