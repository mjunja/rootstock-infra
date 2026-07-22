# =============================================================================
# rootf-test-last-5 - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (ORMONGO_REGION, ORMONGO_RS_URL, ORMONGO_URL)
# are NOT declared or managed here.
# =============================================================================

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

variable "sforce_client_key" {
  description = "Salesforce connected app client key"
  type        = string
  sensitive   = true
}

variable "sforce_client_secret" {
  description = "Salesforce connected app client secret"
  type        = string
  sensitive   = true
}
