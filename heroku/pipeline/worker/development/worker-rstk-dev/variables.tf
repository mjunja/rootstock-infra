# =============================================================================
# worker-rstk-dev - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (CLOUDAMQP_APIKEY, CLOUDAMQP_URL, DATABASE_URL, ORMONGO_REGION, ORMONGO_RS_URL, ORMONGO_URL, PAPERTRAIL_API_TOKEN)
# are NOT declared or managed here.
# =============================================================================

variable "api_usn" {
  description = "API username"
  type        = string
  sensitive   = true
}

variable "api_usnky" {
  description = "API user key"
  type        = string
  sensitive   = true
}

variable "bonsai_url" {
  description = "Bonsai Elasticsearch URL (contains credentials)"
  type        = string
  sensitive   = true
}

variable "maven_repo_password" {
  description = "Maven repository password"
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

variable "dburl" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
}

variable "dburl1" {
  description = "Secondary database connection URL"
  type        = string
  sensitive   = true
}
