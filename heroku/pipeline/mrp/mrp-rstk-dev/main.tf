# =============================================================================
# mrp-rstk-dev - Heroku Application
# =============================================================================
# Part of the "mrp" pipeline, "development" stage.
# Mirrors the live Heroku app.
#
# Pipeline: mrp
#   development: mrp-rstk-dev (this app), mrp-rstk-qa
#   staging:     mrp-rstk-test, mrp-spectra-test
#   production:  mrp-rstk-prod, mrp-prod, mrp-spectra-prod
#
# Shared logic and common defaults live in the rstk-app module; only this app's
# specifics are set below.
# =============================================================================

module "app" {
  source = "../../../modules/rstk-app"

  app_name      = "mrp-rstk-dev"
  pipeline_name = "mrp"
  # pipeline_stage defaults to "development"

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkmrp"
  deploy_branch = "main"
  auto_deploy   = true
  wait_for_ci   = false

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    dashboard = { size = "standard-1x", quantity = 0 }
    myworker  = { size = "standard-1x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    APP_NAME          = "mrp_dev"
    DEBUG_PEITEMID    = "AC_Jan12_101"
    JAVA_OPTS         = "-XX:+UseG1GC -XX:MaxRAMPercentage=80.0 -XX:+UseContainerSupport"
    LOGSTASH_URL      = "https://rootstock-logstash-8a4784f9525f.herokuapp.com"
    NO_NAMESPACE_ORGS = "00DU0000000IF2AMAW,00Dd0000000csD5EAI"
    PGCLIENTENCODING  = "UTF8"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    MONGOLAB_URI     = var.mongolab_uri
    ORMONGO_DBNAME   = var.ormongo_dbname
    ORMONGO_PASSWORD = var.ormongo_password
    ORMONGO_USERNAME = var.ormongo_username
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# Set automatically by the attached add-ons, so intentionally absent above:
#   - DATABASE_URL                     -> heroku-postgresql (billed to mrp-rstk-prod)
#   - ORMONGO_REGION / _RS_URL / _URL  -> ormongo (billed to worker-rstk-dev)
#   - PAPERTRAIL_API_TOKEN             -> papertrail (owned by this app)
