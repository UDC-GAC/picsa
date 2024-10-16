################################################################################
###################                  MWAA                  #####################
################################################################################

output "mwaa_arn" {
  value = aws_mwaa_environment.mwaa.arn
}

output "mwwa_url" {
  value = aws_mwaa_environment.mwaa.webserver_url
}

output "mwaa_status" {
  value = aws_mwaa_environment.mwaa.status
}
