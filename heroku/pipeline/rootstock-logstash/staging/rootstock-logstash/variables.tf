# =============================================================================
# rootstock-logstash - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (none)
# are NOT declared or managed here.
# =============================================================================

variable "elastic_password" {
  description = "Elasticsearch password"
  type        = string
  sensitive   = true
}

variable "elastic_user" {
  description = "Elasticsearch username"
  type        = string
  sensitive   = true
}
