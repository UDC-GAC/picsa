# WatchdogFaaS - AWS

## Description

This project aims to help monitoring AWS Lambda Functions. 

## Components

The application is composed by these elements:
	1. CloudWatch Log Group(s): The groups to be monitorized. They should exist previously to deployment.
	2. Subscription Filter: It fordwards the logs from the given log group to a lambda function, PowerBIForwarder.
	3. PowerBIForwarder: Lambda function that receives the logs events, parses them in real time and forwards to a PowerBI dashboard. After that, store the parsed logs in a DynamoDB table, so they can be analyzed later.
	4. LogStatsForwarder: Lambda function that reads the DynamoDB table and extract general stats from the logs, such as average duration.
	5. PowerBI dashboard: Is feed by streaming datasets built according to the output formats of the lambda functions, described in the next section.

## Formats

All data is sent and stored in JSON format.

### Output format PowerBIForwarder
```json
[
	{
		"id" :"AAAAA555555",
		"source" :"AAAAA555555",
		"timestamp" :"2023-08-09T16:03:44.712Z",
		"duration" :98.6,
		"billedDuration" :98.6,
		"memorySize" :98.6,
		"memoryUsed" :98.6,
		"requestId" :"AAAAA555555",
		"result" :"AAAAA555555"
	}
]
```
### Output format LogsStatsForwarder

```json
[
	{
		"totalInvocations" :98.6,
		"totalSuccesses" :98.6,
		"totalFailures" :98.6,
		"percentageSuccess" :98.6,
		"avgDuration" :98.6,
		"avgSuccessDuration" :98.6,
		"avgFailureDuration" :98.6,
		"avgMemory" :98.6,
		"avgSuccessMemory" :98.6,
		"avgFailureMemory" :98.6,
		"timestamp" :"2023-08-09T16:07:07.065Z",
		"avgMemorySize" :98.6,
		"avgSuccessMemorySize" :98.6,
		"avgFailureMemorySize" :98.6
	}
]
```
### Logs format in DynamoDB
```json
[
	{
		"id" :"AAAAA555555",
		"source" :"AAAAA555555",
		"timestamp" :"2023-08-09T16:03:44.712Z",
		"duration" :98.6,
		"billedDuration" :98.6,
		"memorySize" :98.6,
		"memoryUsed" :98.6,
		"requestId" :"AAAAA555555",
		"result" :"AAAAA555555"
	}
]
```
## Deployment
You can deploy the AWSTemplate.yaml directly from the AWS portal, or run the command:
```
sam deploy --template-file AWSTemplate.yaml --guided
```