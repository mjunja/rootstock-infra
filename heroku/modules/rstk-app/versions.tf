# =============================================================================
# Provider requirements for the rstk-app module
# =============================================================================
# Provider *versions* live here so every app inherits the same constraints from
# one place. Each root app still needs its own `terraform {}` block for
# required_version + backend (Terraform/OpenTofu does not allow sharing those
# across root modules).
# =============================================================================

terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
