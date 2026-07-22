# =============================================================================
# worker-test-last-1 - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-test-last-1"
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
    ARAGING_APP_NAME                                                      = "finreport-rstk-test"
    ARAGING_ONEOFF_DYNO_TYPE                                              = "performance-l"
    ARAGING_PROCESS_NAME                                                  = "newoneoff"
    MRP_APP_NAME                                                          = "mrp-rstk-test"
    MRP_ONEOFF_DYNO_TYPE                                                  = "performance-l"
    MRP_PROCESS_NAME                                                      = "myworker"
    QUEUE_NAME                                                            = "LAST-1"
    RF_APP_NAME                                                           = "rootf-test-last-1"
    RF_ONEOFF_DYNO_TYPE                                                   = "standard-2x"
    RF_PROCFILE_PROCESS_NAME                                              = "rfworker"
    SFORCE_NAMESPACE                                                      = "DOX__"
    STDCOSTS_APP_NAME                                                     = "stdcosts-test"
    STDCOSTS_COSTROLLUP_ONEOFF_DYNO_TYPE                                  = "performance-l"
    STDCOSTS_CSSIMSTDMOVE_ONEOFF_DYNO_TYPE                                = "performance-l"
    STDCOSTS_ICSETMTLSIMCOST_ONEOFF_DYNO_TYPE                             = "standard-2x"
    STDCOSTS_ONEOFF_DYNO_TYPE                                             = "performance-l"
    STDCOSTS_POSETMTLCOST_ONEOFF_DYNO_TYPE                                = "standard-2x"
    STDCOSTS_PROCESS_NAME                                                 = "oneoff"
    aphria_sit_finance_araging_APP_NAME                                   = "finreport-test-last-1"
    aphria_sit_finance_araging_ONEOFF_DYNO_TYPE                           = "performance-l"
    aphria_sit_finance_araging_PROCFILE_PROCESS_NAME                      = "newoneoff"
    aphria_sit_finance_araging_aragingreport_APP_NAME                     = "finreport-test-last-1"
    aphria_sit_finance_araging_aragingreport_ONEOFF_DYNO_TYPE             = "performance-l"
    aphria_sit_finance_araging_aragingreport_PROCFILE_PROCESS_NAME        = "newoneoff"
    aphria_uat_finance_araging_APP_NAME                                   = "finreport-test-last-1"
    aphria_uat_finance_araging_ONEOFF_DYNO_TYPE                           = "performance-l"
    aphria_uat_finance_araging_PROCFILE_PROCESS_NAME                      = "newoneoff"
    aphria_uat_finance_araging_aragingreport_APP_NAME                     = "finreport-test-last-1"
    aphria_uat_finance_araging_aragingreport_ONEOFF_DYNO_TYPE             = "performance-l"
    aphria_uat_finance_araging_aragingreport_PROCFILE_PROCESS_NAME        = "newoneoff"
    cottenham_rspilot_finance_araging_APP_NAME                            = "finreport-test-last-1"
    cottenham_rspilot_finance_araging_ONEOFF_DYNO_TYPE                    = "performance-l"
    cottenham_rspilot_finance_araging_PROCFILE_PROCESS_NAME               = "newoneoff"
    cottenham_rspilot_finance_araging_aragingreport_APP_NAME              = "finreport-test-last-1"
    cottenham_rspilot_finance_araging_aragingreport_ONEOFF_DYNO_TYPE      = "performance-l"
    cottenham_rspilot_finance_araging_aragingreport_PROCFILE_PROCESS_NAME = "newoneoff"
    matouk_sb_erp_mrp_APP_NAME                                            = "mrp-rstk-test"
    matouk_sb_erp_mrp_ONEOFF_DYNO_TYPE                                    = "performance-l"
    matouk_sb_erp_mrp_PROCFILE_PROCESS_NAME                               = "myworker"
    matouk_sb_erp_mrp_planmrp_ONEOFF_DYNO_TYPE                            = "performance-l"
    matouk_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME                      = "myworker"
    mdf_fullsand_finance_araging_APP_NAME                                 = "finreport-test-last-1"
    mdf_fullsand_finance_araging_ONEOFF_DYNO_TYPE                         = "performance-l"
    mdf_fullsand_finance_araging_PROCFILE_PROCESS_NAME                    = "newoneoff"
    mdf_fullsand_finance_araging_aragingreport_APP_NAME                   = "finreport-test-last-1"
    mdf_fullsand_finance_araging_aragingreport_ONEOFF_DYNO_TYPE           = "performance-l"
    mdf_fullsand_finance_araging_aragingreport_PROCFILE_PROCESS_NAME      = "newoneoff"
    mevion_sb_erp_mrp_APP_NAME                                            = "mrp-rstk-test"
    mevion_sb_erp_mrp_ONEOFF_DYNO_TYPE                                    = "performance-l"
    mevion_sb_erp_mrp_PROCFILE_PROCESS_NAME                               = "myworker"
    mevion_sb_erp_mrp_planmrp_APP_NAME                                    = "mrp-rstk-test"
    mevion_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME                      = "myworker"
    osi_sb_erp_mrp_planmrp_APP_NAME                                       = "mrp-rstk-test"
    osi_sb_erp_mrp_planmrp_ONEOFF_DYNO_TYPE                               = "performance-l"
    osi_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME                         = "myworker"
    qarsf_sb_erp_mrp_APP_NAME                                             = "mrp-rstk-test"
    qarsf_sb_erp_mrp_ONEOFF_DYNO_TYPE                                     = "performance-l"
    qarsf_sb_erp_mrp_planmrp_APP_NAME                                     = "mrp-rstk-test"
    qarsf_sb_erp_mrp_planmrp_ONEOFF_DYNO_TYPE                             = "performance-l"
    qarsf_sb_finance_araging_APP_NAME                                     = "finreport-test-last-1"
    qarsf_sb_finance_araging_ONEOFF_DYNO_TYPE                             = "performance-l"
    qarsf_sb_finance_araging_PROCFILE_PROCESS_NAME                        = "newoneoff"
    qarsf_sb_finance_araging_aragingreport_APP_NAME                       = "finreport-test-last-1"
    qarsf_sb_finance_araging_aragingreport_ONEOFF_DYNO_TYPE               = "performance-l"
    qarsf_sb_finance_araging_aragingreport_PROCFILE_PROCESS_NAME          = "newoneoff"
    summittruck_sb_erp_mrp_APP_NAME                                       = "mrp-rstk-test"
    summittruck_sb_erp_mrp_ONEOFF_DYNO_TYPE                               = "performance-l"
    summittruck_sb_erp_mrp_PROCFILE_PROCESS_NAME                          = "myworker"
    summittruck_sb_erp_mrp_planmrp_APP_NAME                               = "mrp-rstk-test"
    summittruck_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME                 = "myworker"
    sunstreet_dev02_sb_erp_mrp_APP_NAME                                   = "mrp-rstk-test"
    sunstreet_dev02_sb_erp_mrp_ONEOFF_DYNO_TYPE                           = "performance-l"
    sunstreet_dev02_sb_erp_mrp_PROCFILE_PROCESS_NAME                      = "myworker"
    sunstreet_dev02_sb_erp_mrp_planmrp_APP_NAME                           = "mrp-rstk-test"
    sunstreet_dev02_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME             = "myworker"
    whiting_sb_erp_mrp_APP_NAME                                           = "mrp-rstk-test"
    whiting_sb_erp_mrp_ONEOFF_DYNO_TYPE                                   = "performance-l"
    whiting_sb_erp_mrp_PROCFILE_PROCESS_NAME                              = "myworker"
    whiting_sb_erp_mrp_planmrp_APP_NAME                                   = "mrp-rstk-test"
    whiting_sb_erp_mrp_planmrp_ONEOFF_DYNO_TYPE                           = "performance-l"
    whiting_sb_erp_mrp_planmrp__PROCFILE_PROCESS_NAME                     = "myworker"
    whiting_sb_finance_araging_APP_NAME                                   = "finreport-test-last-1"
    whiting_sb_finance_araging_ONEOFF_DYNO_TYPE                           = "performance-l"
    whiting_sb_finance_araging_PROCFILE_PROCESS_NAME                      = "newoneoff"
    whiting_sb_finance_araging_aragingreport_APP_NAME                     = "finreport-test-last-1"
    whiting_sb_finance_araging_aragingreport_ONEOFF_DYNO_TYPE             = "performance-l"
    whiting_sb_finance_araging_aragingreport_PROCFILE_PROCESS_NAME        = "newoneoff"
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
