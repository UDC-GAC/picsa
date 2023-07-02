# BDWatchdogFaaS

This project aims to improve the monitoring of serverless functions (FaaS) in multicloud environments.

In order to achieve this goal, we have developed a common data model for the serverless functions' logs of the two main cloud providers (AWS and Azure).
The logs are processed in real-time by a cloud-native application that forwards data to a PowerBI dashboard, allowing to visualize metrics from both AWS Lambda and Azure Functions executions. 
