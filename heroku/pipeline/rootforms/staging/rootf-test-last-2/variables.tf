# =============================================================================
# App Variables
# =============================================================================

variable "app_name" {
  description = "The name of the Heroku app"
  type        = string
  default     = "rootf-test-last-2"
}

variable "region" {
  description = "Heroku region"
  type        = string
  default     = "us"
}

variable "stack" {
  description = "Heroku stack"
  type        = string
  default     = "heroku-22"
}

variable "team_name" {
  description = "Heroku team that owns the app"
  type        = string
  default     = "rootstocksoftware"
}

# =============================================================================
# GitHub Integration & Deployment Branch
# =============================================================================

variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format"
  type        = string
  default     = "rootstockmfg/hkrdocs"
}

variable "deploy_branch" {
  description = "Git branch connected to this app (auto-deploy disabled)"
  type        = string
  default     = "qa-build"
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

# =============================================================================
# Dyno Configuration
# =============================================================================

variable "rfworker_dyno_size" {
  description = "Dyno size for the rfworker process"
  type        = string
  default     = "standard-1x"
}

variable "rfworker_dyno_quantity" {
  description = "Number of rfworker dynos"
  type        = number
  default     = 0
}

# =============================================================================
# Config Vars (non-sensitive)
# =============================================================================

variable "default_mongodb" {
  description = "Default MongoDB provider"
  type        = string
  default     = "ORMONGO"
}

variable "ormongo_region" {
  description = "ObjectRocket MongoDB region"
  type        = string
  default     = "IAD"
}

variable "sforce_namespace" {
  description = "Salesforce package namespace"
  type        = string
  default     = "DOX__"
}

variable "sforce_redirect_url" {
  description = "Salesforce OAuth redirect URL"
  type        = string
  default     = "https://web-rstk-test.herokuapp.com/sf/oauth/callback"
}

# =============================================================================
# Config Vars (sensitive - set via env vars or .tfvars)
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

variable "ormongo_rs_url" {
  description = "ObjectRocket MongoDB replica set URL"
  type        = string
  sensitive   = true
}

variable "ormongo_url" {
  description = "ObjectRocket MongoDB URL"
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
