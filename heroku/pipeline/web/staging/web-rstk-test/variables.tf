# =============================================================================
# web-rstk-test - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (CLOUDAMQP_APIKEY, CLOUDAMQP_URL, ORMONGO_REGION, ORMONGO_RS_URL, ORMONGO_URL, PAPERTRAIL_API_TOKEN)
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

variable "database_url" {
  description = "Database connection URL (manually set - no postgres add-on attached)"
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

variable "aphria_b2b_dbname" {
  description = "aphria_b2b_dbname database name"
  type        = string
  sensitive   = true
}

variable "aphria_sit_dbname" {
  description = "aphria_sit_dbname database name"
  type        = string
  sensitive   = true
}

variable "capcium_rspilot_dbname" {
  description = "capcium_rspilot_dbname database name"
  type        = string
  sensitive   = true
}

variable "cottenham_rspilot_dbname" {
  description = "cottenham_rspilot_dbname database name"
  type        = string
  sensitive   = true
}

variable "daidomachines_rspilot_dbname" {
  description = "daidomachines_rspilot_dbname database name"
  type        = string
  sensitive   = true
}

variable "fike_stage_dbname" {
  description = "fike_stage_dbname database name"
  type        = string
  sensitive   = true
}

variable "matouk_sb_dbname" {
  description = "matouk_sb_dbname database name"
  type        = string
  sensitive   = true
}

variable "mdf_fullsand_dbname" {
  description = "mdf_fullsand_dbname database name"
  type        = string
  sensitive   = true
}

variable "mevion_sb_dbname" {
  description = "mevion_sb_dbname database name"
  type        = string
  sensitive   = true
}

variable "summitbodyworks_sb_dbname" {
  description = "summitbodyworks_sb_dbname database name"
  type        = string
  sensitive   = true
}

variable "summittruck_sb_dbname" {
  description = "summittruck_sb_dbname database name"
  type        = string
  sensitive   = true
}

variable "sunstreet_dev02_sb_dbname" {
  description = "sunstreet_dev02_sb_dbname database name"
  type        = string
  sensitive   = true
}

variable "unionwear_rspilot_dbname" {
  description = "unionwear_rspilot_dbname database name"
  type        = string
  sensitive   = true
}

variable "whiting_sb_dbname" {
  description = "whiting_sb_dbname database name"
  type        = string
  sensitive   = true
}
