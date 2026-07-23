# =============================================================================
# web-rstk-test - Heroku Application
# =============================================================================
# Part of the "web" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "web-rstk-test"
  pipeline_name  = "web"
  pipeline_stage = "staging"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (live values)
  formations = {
    web = { size = "standard-2x", quantity = 1 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    APPS_REDIRECT_URL              = "https://web-rstk-test.herokuapp.com/sf/oauth/callback"
    CAPTURE_POLL_INTERVAL_MINS     = "60"
    CAPTURE_REQUEST_RATE           = "FALSE"
    CATG_SMALL_ORGS                = "00D630000004u1PEAQ"
    ENABLE_REQUEST_RATE_THRESHOLD  = "FALSE"
    ENABLE_STORE_REQUEST_FEATURE   = "TRUE"
    "FIN_VERSIONS_LAST-0"          = "20.131,20.136,20.143,20.155"
    "FIN_VERSIONS_LAST-1"          = "20.124,20.126,20.129,20.130"
    "FIN_VERSIONS_LAST-2"          = ""
    "FIN_VERSIONS_LAST-3"          = ""
    LOG_LEVEL                      = "DEBUG"
    ORG_LIST_CAPTURE_REQUEST_COUNT = ""
    ORMONGO_ORGS                   = ""
    QNAME_B4TICKET_ERP             = "CURR"
    QNAME_B4TICKET_FIN             = "CURR"
    QNAME_B4TICKET_ROOTF           = "LAST-0"
    REQ_THRESHOLD_SMALL            = "500"
    "ROOTF_VERSIONS_LAST-0"        = "1.24,1.21,1.20,1.18,1.19,1.25"
    "ROOTF_VERSIONS_LAST-1"        = "1.31"
    "ROOTF_VERSIONS_LAST-2"        = "1.32,1.33,1.35,1.36,1.37,1.38,1.39"
    "ROOTF_VERSIONS_LAST-3"        = "1.40,1.41,1.42,1.43,1.44"
    "ROOTF_VERSIONS_LAST-4"        = "1.45,1.53,1.55,1.56,1.71,1.74"
    "ROOTF_VERSIONS_LAST-5"        = "25.4,25.6,26.2,26.6,26.12"
    ROUTED_ORGS_1                  = "00DDE0000045QUF2A2"
    ROUTED_ORGS_2                  = "00D53000000QQ2DEAW,00D020000004gCWEAY"
    ROUTED_ORGS_3                  = "00DPw000000KBc1MAG,00DUB000008HQXl2AO,\n00DJX000000Cpra2AC,00D9b000002d6dtEAA,00Dbh000004FXOnEAO,00D9K000004TSLBUA4,00DS800000JCA5GMAX,00DS800000E7sy5MAB,00Ddt000005mVoDEAU"
    ROUTED_QNAME_1                 = "RSLAST-2"
    ROUTED_QNAME_2                 = "ROUTED_2"
    ROUTED_QNAME_3                 = "LAST-3"
    SFORCE_REDIRECT_URL            = "https://web-rstk-test.herokuapp.com/sf/oauth/callback"
    "STDCOSTS_VERSIONS_LAST-0"     = "23.20,23.32,23.38,23.41,23.47,23.54"
    TEST_ORGS                      = ""
    TEST_QNAME                     = "PRERELEASE"
    THRESHOLD_CHECKER_ON           = "FALSE"
    THRESHOLD_TIME_IN_SECS         = "60"
    USE_OLDER_IMPL                 = "FALSE"
    WAIT_TIME_BEFORE_ERRORING_OUT  = "5000"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    APPS_CLIENT_KEY              = var.apps_client_key
    APPS_CLIENT_SECRET           = var.apps_client_secret
    DATABASE_URL                 = var.database_url
    MONGOLAB_URI                 = var.mongolab_uri
    ORMONGO_DBNAME               = var.ormongo_dbname
    ORMONGO_PASSWORD             = var.ormongo_password
    ORMONGO_USERNAME             = var.ormongo_username
    RSTK_KEY                     = var.rstk_key
    SFORCE_CLIENT_KEY            = var.sforce_client_key
    SFORCE_CLIENT_SECRET         = var.sforce_client_secret
    aphria_b2b_dbname            = var.aphria_b2b_dbname
    aphria_sit_dbname            = var.aphria_sit_dbname
    capcium_rspilot_dbname       = var.capcium_rspilot_dbname
    cottenham_rspilot_dbname     = var.cottenham_rspilot_dbname
    daidomachines_rspilot_dbname = var.daidomachines_rspilot_dbname
    fike_stage_dbname            = var.fike_stage_dbname
    matouk_sb_dbname             = var.matouk_sb_dbname
    mdf_fullsand_dbname          = var.mdf_fullsand_dbname
    mevion_sb_dbname             = var.mevion_sb_dbname
    summitbodyworks_sb_dbname    = var.summitbodyworks_sb_dbname
    summittruck_sb_dbname        = var.summittruck_sb_dbname
    sunstreet_dev02_sb_dbname    = var.sunstreet_dev02_sb_dbname
    unionwear_rspilot_dbname     = var.unionwear_rspilot_dbname
    whiting_sb_dbname            = var.whiting_sb_dbname
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
#   - ORMONGO_REGION        -> ormongo (billed to worker-rstk-test)
#   - ORMONGO_RS_URL        -> ormongo (billed to worker-rstk-test)
#   - ORMONGO_URL           -> ormongo (billed to worker-rstk-test)
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
