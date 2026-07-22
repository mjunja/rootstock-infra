# =============================================================================
# worker-test-last-4 - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-test-last-4"
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
    ARAGING_APP_NAME                          = "finreport-rstk-test"
    ARAGING_ONEOFF_DYNO_TYPE                  = "performance-l"
    ARAGING_PROCESS_NAME                      = "newoneoff"
    LOG_LEVEL                                 = "DEBUG"
    MRP_APP_NAME                              = "mrp-rstk-test"
    MRP_ONEOFF_DYNO_TYPE                      = "performance-l"
    MRP_PROCESS_NAME                          = "myworker"
    QUEUE_NAME                                = "LAST-4"
    RF_APP_NAME                               = "rootf-test-last-4"
    RF_ONEOFF_DYNO_TYPE                       = "standard-2x"
    RF_PROCFILE_PROCESS_NAME                  = "rfworker"
    SFORCE_NAMESPACE                          = "DOX__"
    STDCOSTS_APP_NAME                         = "stdcosts-test"
    STDCOSTS_COSTROLLUP_ONEOFF_DYNO_TYPE      = "performance-l"
    STDCOSTS_CSSIMSTDMOVE_ONEOFF_DYNO_TYPE    = "performance-l"
    STDCOSTS_ICSETMTLSIMCOST_ONEOFF_DYNO_TYPE = "standard-2x"
    STDCOSTS_ONEOFF_DYNO_TYPE                 = "performance-l"
    STDCOSTS_POSETMTLCOST_ONEOFF_DYNO_TYPE    = "standard-2x"
    STDCOSTS_PROCESS_NAME                     = "oneoff"
    supportedLocale                           = "de_AT,sv_SE"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    API_USN              = var.api_usn
    API_USNKY            = var.api_usnky
    CLOUDAMQP_APIKEY     = var.cloudamqp_apikey
    CLOUDAMQP_URL        = var.cloudamqp_url
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
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
