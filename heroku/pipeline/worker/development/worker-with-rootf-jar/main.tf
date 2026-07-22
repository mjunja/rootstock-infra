# =============================================================================
# worker-with-rootf-jar - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "development" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-with-rootf-jar"
  pipeline_name  = "worker"
  # pipeline_stage defaults to "development"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (live values)
  formations = {
    worker = { size = "standard-2x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    LOG_LEVEL                                                 = "DEBUG"
    QUEUE_NAME                                                = "CURR"
    RF_APP_NAME                                               = "rootf-dev"
    RF_ONEOFF_DYNO_TYPE                                       = "standard-2x"
    RF_PROCFILE_PROCESS_NAME                                  = "rfworker"
    SFORCE_NAMESPACE                                          = "DOX__"
    pde3_erp_mrp_planmrp_APP_NAME                             = "mrp-rstk-dev"
    pde3_erp_mrp_planmrp_PROCFILE_PROCESS_NAME                = "myworker"
    pde3_erp_stdcosts_costrollup_APP_NAME                     = "stdcosts-dev"
    pde3_erp_stdcosts_costrollup_PROCFILE_PROCESS_NAME        = "oneoff"
    pde3f_finance_araging_APP_NAME                            = "finreport-rstk-dev"
    pde3f_finance_araging_ONEOFF_DYNO_TYPE                    = "performance-l"
    pde3f_finance_araging_PROCFILE_PROCESS_NAME               = "newoneoff"
    pde3f_finance_araging_aragingreport_APP_NAME              = "finreport-rstk-dev"
    pde3f_finance_araging_aragingreport_ONEOFF_DYNO_TYPE      = "performance-l"
    pde3f_finance_araging_aragingreport_PROCFILE_PROCESS_NAME = "newoneoff"
    pde5_erp_stdcosts_costrollup_APP_NAME                     = "stdcosts-dev"
    pde5_erp_stdcosts_costrollup_PROCFILE_PROCESS_NAME        = "oneoff"
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
#   - CLOUDAMQP_APIKEY      -> cloudamqp (billed to web-rstk-dev)
#   - CLOUDAMQP_URL         -> cloudamqp (billed to web-rstk-dev)
#   - DATABASE_URL          -> heroku-postgresql
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
