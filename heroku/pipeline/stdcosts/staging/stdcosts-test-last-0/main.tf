# =============================================================================
# stdcosts-test-last-0 - Heroku Application
# =============================================================================
# Part of the "stdcosts" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "stdcosts-test-last-0"
  pipeline_name  = "stdcosts"
  pipeline_stage = "staging"

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    oneoff = { size = "standard-1x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    JAVA_OPTS        = "-XX:+UseG1GC -Xmx8g -Xms2g"
    PGCLIENTENCODING = "UTF8"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    CLOUDAMQP_APIKEY = var.cloudamqp_apikey
    CLOUDAMQP_URL    = var.cloudamqp_url
    ORMONGO_DBNAME   = var.ormongo_dbname
    ORMONGO_PASSWORD = var.ormongo_password
    ORMONGO_USERNAME = var.ormongo_username
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - DATABASE_URL          -> heroku-postgresql
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
