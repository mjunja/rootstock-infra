# =============================================================================
# rstk-app module - Inputs
# =============================================================================
# A reusable module for a Rootstock Heroku app: the app itself, its pipeline
# coupling, dyno formation, the (optional) Papertrail add-on, and GitHub
# auto-deploy wiring. App-specific values are passed in; values that are common
# across all apps default here (region, stack, team) or in locals.tf
# (base config vars).
# =============================================================================

# -----------------------------------------------------------------------------
# Common platform settings (shared defaults - change here to change everywhere)
# -----------------------------------------------------------------------------
variable "region" {
  description = "Heroku region"
  type        = string
  default     = "us"
}

variable "stack" {
  description = "Heroku stack"
  type        = string
  default     = "heroku-24"
}

variable "team_name" {
  description = "Heroku team that owns the app"
  type        = string
  default     = "rootstocksoftware"
}

# -----------------------------------------------------------------------------
# App identity
# -----------------------------------------------------------------------------
variable "app_name" {
  description = "The name of the Heroku app"
  type        = string
}

# -----------------------------------------------------------------------------
# Pipeline
# -----------------------------------------------------------------------------
variable "pipeline_name" {
  description = "Name of the existing Heroku pipeline this app belongs to"
  type        = string
}

variable "pipeline_stage" {
  description = "Pipeline stage for this app (development, staging, production)"
  type        = string
  default     = "development"
}

# -----------------------------------------------------------------------------
# GitHub integration & deployment branch
# -----------------------------------------------------------------------------
variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format"
  type        = string
}

variable "deploy_branch" {
  description = "Git branch that auto-deploys to this app"
  type        = string
}

variable "auto_deploy" {
  description = "Enable auto-deploy on push to deploy_branch"
  type        = bool
  default     = false
}

variable "wait_for_ci" {
  description = "Wait for CI to pass before auto-deploying"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Dyno formation
# -----------------------------------------------------------------------------
variable "formations" {
  description = "Map of process type => { size, quantity } for dyno formation"
  type = map(object({
    size     = string
    quantity = number
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------
variable "papertrail_plan" {
  description = "Papertrail add-on plan (e.g. papertrail:choklad). Set to null to not manage a Papertrail add-on."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Config vars
# -----------------------------------------------------------------------------
variable "config_vars" {
  description = "App-specific non-sensitive config vars. Merged over the shared base in locals.tf (this map wins on conflict)."
  type        = map(string)
  default     = {}
}

variable "sensitive_config_vars" {
  description = "Sensitive config vars (e.g. ORMONGO_* secrets). Supplied via tfvars / TF_VAR env vars - never hardcoded."
  type        = map(string)
  default     = {}
  sensitive   = true
}
