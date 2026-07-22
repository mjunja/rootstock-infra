# =============================================================================
# stdcosts-test - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (DATABASE_URL, ORMONGO_REGION, ORMONGO_RS_URL, ORMONGO_URL, PAPERTRAIL_API_TOKEN)
# are NOT declared or managed here.
# =============================================================================

variable "cloudamqp_apikey" {
  description = "CloudAMQP API key"
  type        = string
  sensitive   = true
}

variable "cloudamqp_url" {
  description = "CloudAMQP connection URL"
  type        = string
  sensitive   = true
}

variable "ormongo_dbname" {
  description = "ObjectRocket MongoDB database name"
  type        = string
  sensitive   = true
}

variable "ormongo_password" {
  description = "ObjectRocket MongoDB password"
  type        = string
  sensitive   = true
}

variable "ormongo_username" {
  description = "ObjectRocket MongoDB username"
  type        = string
  sensitive   = true
}
