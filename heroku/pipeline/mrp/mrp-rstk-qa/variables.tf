# =============================================================================
# App Variables
# =============================================================================

variable "app_name" {
  description = "The name of the Heroku app"
  type        = string
  default     = "mrp-rstk-qa"
}

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

# =============================================================================
# GitHub Integration & Deployment Branch
# =============================================================================

variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format"
  type        = string
  default     = "rootstockmfg/hkmrp"
}

variable "deploy_branch" {
  description = "Git branch that auto-deploys to this app"
  type        = string
  default     = "main"
}

variable "auto_deploy" {
  description = "Enable auto-deploy on push to deploy_branch"
  type        = bool
  default     = true
}

variable "wait_for_ci" {
  description = "Wait for CI to pass before auto-deploying"
  type        = bool
  default     = true
}

# =============================================================================
# Dyno Configuration
# =============================================================================

variable "dashboard_dyno_size" {
  description = "Dyno size for the dashboard process"
  type        = string
  default     = "standard-1x"
}

variable "dashboard_dyno_quantity" {
  description = "Number of dashboard dynos"
  type        = number
  default     = 1
}

# =============================================================================
# Config Vars (non-sensitive)
# =============================================================================

variable "app_config_name" {
  description = "Application name config var"
  type        = string
  default     = "mrp_qa"
}

variable "java_opts" {
  description = "JVM options"
  type        = string
  default     = "-XX:+UseG1GC -XX:MaxRAMPercentage=80.0 -XX:+UseContainerSupport"
}

variable "default_mongodb" {
  description = "Default MongoDB provider"
  type        = string
  default     = "ORMONGO"
}

variable "logstash_url" {
  description = "Logstash endpoint URL"
  type        = string
  default     = "https://rootstock-logstash-8a4784f9525f.herokuapp.com"
}

variable "no_namespace_orgs" {
  description = "Salesforce org IDs without namespace"
  type        = string
  default     = "00Dd0000000csD5EAI"
}

variable "pgclient_encoding" {
  description = "PostgreSQL client encoding"
  type        = string
  default     = "UTF8"
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

variable "ormongo_region" {
  description = "ObjectRocket MongoDB region"
  type        = string
  default     = "IAD"
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
