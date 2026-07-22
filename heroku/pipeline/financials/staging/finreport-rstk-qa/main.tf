# =============================================================================
# finreport-rstk-qa - Heroku Application
# =============================================================================
# Part of the "financials" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "finreport-rstk-qa"
  pipeline_name  = "financials"
  pipeline_stage = "staging"

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkarag"
  deploy_branch = "main"
  auto_deploy   = true
  wait_for_ci   = false

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (running 1 dyno)
  formations = {
    newoneoff = { size = "standard-1x", quantity = 1 }
  }

config_vars = {
    APP_NAME                  = "finreport_qa"
    JAVA_OPTS                 = "-XX:+UseG1GC -Xmx8g -Xms1g"
    PGCLIENTENCODING          = "UTF8"
    LOGSTASH_URL              = "https://rootstock-logstash-8a4784f9525f.herokuapp.com"
  }
  
  # Non-sensitive config vars: live app only sets DEFAULT_MONGODB=ORMONGO, which
  # comes from the module base, so there is nothing app-specific to add here.

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    ORMONGO_DBNAME   = var.ormongo_dbname
    ORMONGO_PASSWORD = var.ormongo_password
    ORMONGO_USERNAME = var.ormongo_username
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# Set automatically by the attached add-ons, so intentionally absent above:
#   - DATABASE_URL                     -> heroku-postgresql (billed to mrp-rstk-prod)
#   - ORMONGO_REGION / _RS_URL / _URL  -> ormongo (billed to worker-rstk-dev)
#   - PAPERTRAIL_API_TOKEN             -> papertrail (owned by this app)
