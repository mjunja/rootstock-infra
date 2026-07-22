# =============================================================================
# rootf-qa - Heroku Application
# =============================================================================
# Part of the "rootforms" pipeline, "development" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "rootf-qa"
  pipeline_name  = "rootforms"
  # pipeline_stage defaults to "development"
  stack         = "heroku-22"  # differs from the module default

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkrdocs"
  deploy_branch = "released-build"
  auto_deploy   = false
  wait_for_ci   = true

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    rfworker = { size = "standard-1x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    LOG_LEVEL               = "DEBUG"
    SFORCE_NAMESPACE        = "DOX__"
    SOAP_APIVERSION_OVRRIDE = "45.0"
    supportedLocale         = "de_AT,sv_SE,de_DE,en_DE,de_EN"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    HEROKU_PASSWORD      = var.heroku_password
    HEROKU_USERNAME      = var.heroku_username
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
