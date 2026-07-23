# =============================================================================
# mrp-rstk-qa - Inputs
# =============================================================================
# All sensitive config var values arrive through this single map, supplied via
# terraform.tfvars (gitignored) or TF_VAR_secrets. The keys this app expects
# are the ones referenced as var.secrets["..."] in main.tf and listed in
# terraform.tfvars.example.
# =============================================================================

variable "secrets" {
  description = "Sensitive config var values, keyed by config var name"
  type        = map(string)
  sensitive   = true
  default     = {}
}
