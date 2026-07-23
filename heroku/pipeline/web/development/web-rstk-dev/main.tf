# =============================================================================
# web-rstk-dev - Heroku Application
# =============================================================================
# Part of the "web" pipeline, "development" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "web-rstk-dev"
  pipeline_name  = "web"
  # pipeline_stage defaults to "development"
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
    APPS_REDIRECT_URL            = "https://web-rstk-dev.herokuapp.com/sf/oauth/callback"
    BOTH_MONGOS                  = "false"
    CAPTURE_REQUEST_RATE         = "true"
    CATG_LARGE_ORGS              = "00D36000001Ee5MEAS"
    ENABLE_STORE_REQUEST_FEATURE = "TRUE"
    LOG_LEVEL                    = "DEBUG"
    "MRP_VERSIONS_LAST-3"        = "19.20-23.93"
    NO_NAMESPACE_ORGS            = "00DU00000"
    ORMONGO_ORGS                 = ""
    QNAME_B4TICKET_ROOTF         = "CURR"
    REQ_THRESHOLD_LARGE          = "25"
    "ROOTF_VERSIONS_LAST-0"      = "1.19-1.25"
    SFORCE_REDIRECT_URL          = "https://web-rstk-dev.herokuapp.com/sf/oauth/callback"
    SRC_ORG_QNAME                = "CURR"
    STORE_LEAST_NO_OF_PARMS      = "TRUE"
    THRESHOLD_TIME_IN_SECS       = "60"
    USE_OLDER_IMPL               = "FALSE"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    APPS_CLIENT_KEY      = var.apps_client_key
    APPS_CLIENT_SECRET   = var.apps_client_secret
    MONGOLAB_URI         = var.mongolab_uri
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_USERNAME     = var.ormongo_username
    RSTK_KEY             = var.rstk_key
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
    devqaff_dbname       = var.devqaff_dbname
    pde3_dbname          = var.pde3_dbname
    pde3f_dbname         = var.pde3f_dbname
    pde5_dbname          = var.pde5_dbname
    pde5f_dbname         = var.pde5f_dbname
    qarsf_dbname         = var.qarsf_dbname
  }
}

# -----------------------------------------------------------------------------
# cloudamqp - owned by THIS app
# -----------------------------------------------------------------------------
resource "heroku_addon" "cloudamqp" {
  app_id = module.app.app_id
  plan   = "cloudamqp:squirrel-1"
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
