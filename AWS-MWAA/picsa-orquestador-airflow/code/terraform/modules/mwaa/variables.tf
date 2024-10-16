################################################################################
###################                  MWAA                  #####################
################################################################################

variable "name" {
  type = string
  description = "The name of the Apache Airflow Environment"
}

variable "dags_s3_bucket" {
  type = string
  description = "The Amazon Resource Name (ARN) of your Amazon S3 storage bucket"
}

variable "dags_s3_path" {
  type = string
  description = "The relative path to the DAG folder on your Amazon S3 storage bucket"
}

variable "execution_role_arn" {
  type = string
  description = "The Amazon Resource Name (ARN) of the task execution role that the Amazon MWAA and its environment can assume"
}

variable "environment_class" {
  type = string
  description = "Environment class for the cluster"
}

variable "mwaa_min_workers" {
  type = string
  description = "The minimum number of workers that you want to run in your environment"
}

variable "mwaa_max_workers" {
  type = string
  description = "The maximum number of workers that can be automatically scaled up"
}

variable "webserver_access_mode" {
  type = string
  description = "Specifies whether the webserver should be accessible over the internet or via your specified VPC"
}

variable "security_group_ids" {
  type = list(string)
  description = "Security groups IDs for the environment"
}

variable "subnets_ids" {
  type = list(string)
  description = "The private subnet IDs in which the environment should be created. MWAA requires two subnets"
}

variable "dag_logs" {
  type = bool
  description = "Log configuration options for processing DAGs"
}

variable "dag_log_level" {
  type = string
  description = "Logging level for processing DAGs"
}

variable "scheduler_logs" {
  type = bool
  description = "Log configuration options for the schedulers"
}

variable "scheduler_log_level" {
  type = string
  description = "Logging level for the schedulers"
}

variable "task_logs" {
  type = string
  description = "Log configuration options for DAG tasks"
}

variable "task_log_level" {
  type = string
  description = "Logging level for DAG tasks"
}

variable "webserver_logs" {
  type = string
  description = "Log configuration options for the webservers"
}

variable "webserver_log_level" {
  type = string
  description = "Logging level for the webservers"
}

variable "worker_logs" {
  type = string
  description = "Log configuration options for the workers"
}

variable "worker_log_level" {
  type = string
  description = "Logging level for the workers"
}
