bucket               = "torusware-terraform-states"
key                  = "terraform.tfstate"
workspace_key_prefix = "invoke-lambda"
dynamodb_table       = "torusware-terraform-states-lock-id"
region               = "eu-west-1"