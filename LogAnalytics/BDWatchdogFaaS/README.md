# BDWatchdogFaaS

This project aims to improve the monitoring of serverless functions (FaaS) in multicloud environments.

In order to achieve this goal, we have developed a common data model for the serverless functions' logs of the two main cloud providers (AWS and Azure).
The logs are processed in real-time by a cloud-native application that forwards data to a PowerBI dashboard, allowing to visualize metrics from both AWS Lambda and Azure Functions executions. 

Software [BDWatchdogFaaS](https://serverlessrepo.aws.amazon.com/applications/eu-central-1/137253520060/BDWatchdogFaaS) available at [Amazon Web Services - Serverless Applications Repository (SAR)](https://serverlessrepo.aws.amazon.com/applications) (search for tags multicloud, FaaS or PICSA).

Further details at this paper:

_Manuel Framil, Mario Carpente, David Fraga, Jonatan Enes, Roberto R. Expósito, Guillermo L. Taboada, Juan Touriño. **BDWatchdogFaaS: A Tool for Monitoring and Analysis of Functions-as-a-Service in Cloud Environment**. VI Congreso XoveTIC: Impulsando el Talento Científico, pp. 351-355. A Coruña, October 2023_
https://doi.org/10.17979/spudc.000024.52
