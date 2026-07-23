# =============================================================================
# web-rstk-qa - Heroku Application
# =============================================================================
# Part of the "web" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "web-rstk-qa"
  pipeline_name  = "web"
  pipeline_stage = "staging"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (live values)
  formations = {
    web = { size = "standard-1x", quantity = 1 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    APPS_REDIRECT_URL            = "https://web-rstk-qa.herokuapp.com/sf/oauth/callback"
    CAPTURE_POLL_INTERVAL_MINS   = "60"
    CAPTURE_REQUEST_RATE         = "true"
    CATG_SMALL_ORGS              = "00D1a000000ZQ8oEAG"
    ENABLE_STORE_REQUEST_FEATURE = "TRUE"
    LOG_LEVEL                    = "DEBUG"
    QNAME_B4TICKET_ROOTF         = "LAST-0"
    REQ_THRESHOLD_SMALL          = "10"
    "ROOTF_VERSIONS_LAST-0"      = ""
    ROUTED_ORGS_2                = ""
    ROUTED_ORGS_3                = ""
    ROUTED_ORGS_5                = ""
    ROUTED_QNAME_1               = "ROUTED_1"
    ROUTED_QNAME_2               = "ROUTED_2"
    ROUTED_QNAME_3               = "ROUTED_3"
    ROUTED_QNAME_5               = "ROUTED_5"
    SFORCE_REDIRECT_URL          = "https://web-rstk-qa.herokuapp.com/sf/oauth/callback"
    SRC_ORG_QNAME                = "CURR"
    "STDCOSTS_VERSIONS_LAST-0"   = ""
    TEST_ORGS                    = ""
    TEST_QNAME                   = ""
    USE_OLDER_IMPL               = "FALSE"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    APPS_CLIENT_KEY      = var.apps_client_key
    APPS_CLIENT_SECRET   = var.apps_client_secret
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_USERNAME     = var.ormongo_username
    RSTK_KEY             = var.rstk_key
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
    pde5_dbname          = var.pde5_dbname
  }
}

# -----------------------------------------------------------------------------
# cloudamqp - owned by THIS app
# -----------------------------------------------------------------------------
resource "heroku_addon" "cloudamqp" {
  app_id = module.app.app_id
  plan   = "cloudamqp:lemur"
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - CLOUDAMQP_APIKEY      -> cloudamqp (owned by this app)
#   - CLOUDAMQP_URL         -> cloudamqp (owned by this app)
#   - DATABASE_URL          -> heroku-postgresql (billed to mrp-rstk-prod)
#   - ORMONGO_REGION        -> ormongo (billed to worker-rstk-dev)
#   - ORMONGO_RS_URL        -> ormongo (billed to worker-rstk-dev)
#   - ORMONGO_URL           -> ormongo (billed to worker-rstk-dev)
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
