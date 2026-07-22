# =============================================================================
# stdcosts-dev - Heroku Application
# =============================================================================
# Part of the "stdcosts" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "stdcosts-dev"
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
    LOG_LEVEL         = "FINEST"
    NO_NAMESPACE_ORGS = "00DU0000000IF2AMAW,00Dd0000000csD5EAI"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    MONGOLAB_URI     = var.mongolab_uri
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
