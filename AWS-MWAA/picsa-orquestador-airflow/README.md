[![GNU GPLv3 License][license-shield]][license-url]
[![Docker Compose Validation](https://github.com/torusware/picsa-orquestador-airflow/actions/workflows/validate-compose.yml/badge.svg?branch=main)](https://github.com/torusware/picsa-orquestador-airflow/actions/workflows/validate-compose.yml)
[![Terraform Validation](https://github.com/torusware/picsa-orquestador-airflow/actions/workflows/validate-terraform.yml/badge.svg)](https://github.com/torusware/picsa-orquestador-airflow/actions/workflows/validate-terraform.yml)

# Terraform AWS MWAA Quick Start

Quick start tutorial for Amazon Managed Workflows for Apache Airflow (MWAA) with Terraform. This is a word for word translation of the official [AWS quick start](https://docs.aws.amazon.com/mwaa/latest/userguide/quick-start.html) with CloudFormation, which means that the same AWS resources are deployed with the two projects.

## Workflow

We recommend to use the Docker project to test new functionalities from Apache Airflow. With Docker project, you can select which Apache Airflow Docker image want to use, being able to be the latest one.

To use an stable version, it is prefered to use the Terraform Project. The Apache Airflow version is the used by AWS MWAA service. To check that current version, check [this link](https://docs.aws.amazon.com/mwaa/latest/userguide/airflow-versions.html).

## Tool versions

This project use [asdf](https://asdf-vm.com/) to manage tool versions. The [.tool-versions](./.tool-versions) contains the list of the tools used on this project with their versions.

The following tools are used:
  * Terraform v1.2.8
  * Python 3.9.6 is used to code the DAGs scripts

## Projects execution

### Docker Compose

To use and operate with the Docker Compose project, located on `code/docker` folder, use the following commands:

```bash
# Got to the Docker folder
cd code/docker

# Deploy docker-compose.yaml services
docker compose up -d

# Check status of docker-compose.yaml services
docker compose ps
```

If you deploy Docker Compose locally, access to Apache Airflow through `http://localhost:8080`.

### Terraform

Terraform project is located at `code/terraform`. It follows a modular structure, to create a new resource you need to add it on `code/terraform/environment/<environment_name>/main.tf`.

#### Prerequisites

This Terraform project uses [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). 

To deploy an environment, you need to configure [AWS CLI](https://aws.amazon.com/cli/) with Access Key, Secret Access Key and AWS region. Also, your IAM user MUST have permissions to create all resources on this Terraform project. 

#### Deployment

After configure your local, run the following commands:

```bash
# Go to the Terraform folder
cd code/terraform

# Go to the environment folder that you want to deploy
cd environments/<environment_name>

# Configure your AWS CLI to points to the AWS account to deploy Terraform resources (interactive)
aws configure

# Or configure your AWS_PROFILE with you AWS CLI profile (non-interactive)
export AWS_PROFILE="<profile_name>"

# Inizcialize the Terraform project
terraform init -backend-config="./backend.tfvars"

# Execute terraform plan
terraform plan -output="./plan.output/plan" >> ./plan-output/plan.txt

# Apply the plan
terraform apply ./plan-output/plan
```

To access to Apache Airflow, you can access to the AWS MWAA Service through AWS Console, or execute `terraform output mwwa_url` to obtain the URL.

## DAGs

There are test DAGs files inside the local [`code/dags` directory](./code/dags), which was taken from the official tutorial for [Apache Airflow v1.10.12](https://airflow.apache.org/docs/apache-airflow/1.10.12/tutorial.html#example-pipeline-definition). You can place as many DAG files inside that directory as you want and Terraform will pick them up and upload them to S3. Alternatively, you can use the DAG sync via GitHub Actions as described [below](#dags-s3-sync).

## GitHub Actions

These Github Actions are executed only on Pull Request that modifies their respective files (`code/terraform`, `code/docker` and `code/dags`).

### Terraform validation

There is a Github Action to validate the terraform project. We encourage to the developers to use `terraform fmt` (check `-check` and `-diff` options) and `terraform validate` commands because these commands are used on this Action to validate the project.

In this action, `terraform plan` is executed, and command output is exposed as a comment on the PR.

### Docker Compose validation

There is a Github Action to validate `code/docker/docker-compose.yaml` file. [Yamllint](https://github.com/adrienverge/yamllint) configuration file with custom rules for Docker Compose files is used as a linter.

### DAGs S3 sync

To use GitHub actions to sync the `dags` folder to S3, we can use the workflow in `.github/workflows/sync.yml`. Also, Python files are validate by [Flake8](https://flake8.pycqa.org/en/latest/index.html) linter.

To allow access, set up secrets via `Settings -> Secrets` and add the below variables, which you can read from the `terraform output`:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET`

<!-- VARIABLES -->
[license-shield]: https://img.shields.io/badge/License-GNU%20GPLv3-yellow
[license-url]: https://github.com/torusware/picsa-orquestador-airflow/blob/main/LICENSE
