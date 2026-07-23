# =============================================================================
# web-rstk-dev - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (CLOUDAMQP_APIKEY, CLOUDAMQP_URL, DATABASE_URL, ORMONGO_REGION, ORMONGO_RS_URL, ORMONGO_URL, PAPERTRAIL_API_TOKEN)
# are NOT declared or managed here.
# =============================================================================

variable "apps_client_key" {
  description = "Apps connected app client key"
  type        = string
  sensitive   = true
}

variable "apps_client_secret" {
  description = "Apps connected app client secret"
  type        = string
  sensitive   = true
}

variable "mongolab_uri" {
  description = "MongoLab connection URI"
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

variable "rstk_key" {
  description = "Rootstock API key"
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

variable "devqaff_dbname" {
  description = "devqaff_dbname database name"
  type        = string
  sensitive   = true
}

variable "pde3_dbname" {
  description = "pde3_dbname database name"
  type        = string
  sensitive   = true
}

variable "pde3f_dbname" {
  description = "pde3f_dbname database name"
  type        = string
  sensitive   = true
}

variable "pde5_dbname" {
  description = "pde5_dbname database name"
  type        = string
  sensitive   = true
}

variable "pde5f_dbname" {
  description = "pde5f_dbname database name"
  type        = string
  sensitive   = true
}

variable "qarsf_dbname" {
  description = "qarsf_dbname database name"
  type        = string
  sensitive   = true
}
