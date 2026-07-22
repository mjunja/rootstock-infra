# =============================================================================
# worker-qa-last-0 - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-qa-last-0"
  pipeline_name  = "worker"
  pipeline_stage = "staging"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Dyno formation (live values)
  formations = {
    worker = { size = "standard-1x", quantity = 1 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    QUEUE_NAME                                = "LAST-0"
    RF_APP_NAME                               = "rootf-qa-last-0"
    RF_ONEOFF_DYNO_TYPE                       = "standard-2x"
    RF_PROCFILE_PROCESS_NAME                  = "rfworker"
    SFORCE_NAMESPACE                          = "DOX__"
    qarsf_sb_erp_mrp_APP_NAME                 = "mrp-rstk-qa"
    qarsf_sb_erp_mrp_ONEOFF_DYNO_TYPE         = "performance-l"
    qarsf_sb_erp_mrp_planmrp_APP_NAME         = "mrp-rstk-qa"
    qarsf_sb_erp_mrp_planmrp_ONEOFF_DYNO_TYPE = "performance-l"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
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
#   - CLOUDAMQP_APIKEY  -> cloudamqp (billed to web-rstk-qa)
#   - CLOUDAMQP_URL     -> cloudamqp (billed to web-rstk-qa)
#   - ORMONGO_REGION    -> ormongo
#   - ORMONGO_RS_URL    -> ormongo
#   - ORMONGO_URL       -> ormongo
