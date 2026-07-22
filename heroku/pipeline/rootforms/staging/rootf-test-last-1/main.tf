# =============================================================================
# rootf-test-last-1 - Heroku Application
# =============================================================================
# Part of the "rootforms" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "rootf-test-last-1"
  pipeline_name  = "rootforms"
  pipeline_stage = "staging"
  stack         = "heroku-20"  # differs from the module default

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkrdocs"
  deploy_branch = "qa-build"
  auto_deploy   = false
  wait_for_ci   = false

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    rfworker = { size = "performance-l", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    SFORCE_NAMESPACE    = "DOX__"
    SFORCE_REDIRECT_URL = "https://web-rstk-test.herokuapp.com/sf/oauth/callback"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_USERNAME     = var.ormongo_username
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
