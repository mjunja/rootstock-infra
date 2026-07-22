# =============================================================================
# finreport-rstk-dev - Heroku Application
# =============================================================================
# Part of the "financials" pipeline, "development" stage.
# Mirrors the live Heroku app. Shared logic and common defaults (region, stack,
# team, DEFAULT_MONGODB, PGCLIENTENCODING, GitHub auto-deploy wiring) live in
# the rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name      = "finreport-rstk-dev"
  pipeline_name = "financials"
  # pipeline_stage defaults to "development"

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkarag"
  deploy_branch = "main"
  auto_deploy   = true
  wait_for_ci   = true

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    newoneoff = { size = "standard-1x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    APP_NAME                  = "finreport_dev"
    JAVA_OPTS                 = "-XX:+UseG1GC -Xmx8g -Xms1g"
    PGCLIENTENCODING          = "UTF8"
    maxRowsPerBatchBulkInsert = "10000"
    LOGSTASH_URL              = "https://rootstock-logstash-8a4784f9525f.herokuapp.com"
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
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - DATABASE_URL                     -> heroku-postgresql (billed to mrp-rstk-prod)
#   - ORMONGO_REGION / _RS_URL / _URL  -> ormongo (billed to worker-rstk-dev)
#   - PAPERTRAIL_API_TOKEN             -> papertrail (owned by this app)
