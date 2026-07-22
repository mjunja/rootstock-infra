# =============================================================================
# worker-rstk-qa - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-rstk-qa"
  pipeline_name  = "worker"
  pipeline_stage = "staging"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (live values)
  formations = {
    worker = { size = "standard-2x", quantity = 1 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    APP_NAME                  = "worker_qa"
    ARAGING_APP_NAME          = "finreport-rstk-qa"
    ARAGING_ONEOFF_DYNO_TYPE  = "performance-l"
    ARAGING_PROCESS_NAME      = "newoneoff"
    DEVTESTING                = "true"
    DisableFieldLevelCallback = "false"
    LOGSTASH_URL              = "https://rootstock-logstash-8a4784f9525f.herokuapp.com"
    LOG_LEVEL                 = "DEBUG"
    MRP_APP_NAME              = "mrp-rstk-qa"
    MRP_ONEOFF_DYNO_TYPE      = "performance-l"
    MRP_PROCESS_NAME          = "myworker"
    QUEUE_NAME                = "CURR"
    RF_APP_NAME               = "rootf-qa"
    RF_ONEOFF_DYNO_TYPE       = "standard-2x"
    RF_PROCFILE_PROCESS_NAME  = "rfworker"
    SFORCE_NAMESPACE          = "DOX__"
    SPIN_PERFORMANCE_L_BEYOND = "0"
    STDCOSTS_APP_NAME         = "stdcosts-qa"
    STDCOSTS_ONEOFF_DYNO_TYPE = "performance-l"
    STDCOSTS_PROCESS_NAME     = "oneoff"
    supportedLocale           = "de_AT,sv_SE,de_DE,en_DE,en_NL,nl_NL,en_US"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    API_USN              = var.api_usn
    API_USNKY            = var.api_usnky
    HEROKU_PASSWORD      = var.heroku_password
    HEROKU_USERNAME      = var.heroku_username
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_USERNAME     = var.ormongo_username
    RSTK_KEY             = var.rstk_key
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - CLOUDAMQP_APIKEY      -> cloudamqp (billed to web-rstk-qa)
#   - CLOUDAMQP_URL         -> cloudamqp (billed to web-rstk-qa)
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
