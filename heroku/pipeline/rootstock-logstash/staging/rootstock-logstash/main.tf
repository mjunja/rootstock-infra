# =============================================================================
# rootstock-logstash - Heroku Application
# =============================================================================
# Part of the "rootstock-logstash" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "rootstock-logstash"
  pipeline_name  = "rootstock-logstash"
  pipeline_stage = "staging"
  stack          = "container"  # differs from the module default

  # GitHub integration (live values)
  github_repo   = "mjunja/rootstock-logstash"
  deploy_branch = "main"
  auto_deploy   = true
  wait_for_ci   = false

  # Dyno formation (live values)
  formations = {
    web = { size = "performance-m", quantity = 1 }
  }

  # Non-sensitive config vars.
  # NOTE: this app has no DEFAULT_MONGODB set live; the module base adds
  # DEFAULT_MONGODB=ORMONGO on first apply.
  config_vars = {
    ELASTICSEARCH_HOST = "https://c21fdff3e29d4fe28ddc62ab31052140.us-east-1.aws.found.io:443"
    JAVA_TOOL_OPTIONS  = "-Xmx256m -Xms128m"
    LS_JAVA_OPTS       = "-Xms128m -Xmx256m"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    ELASTIC_PASSWORD = var.elastic_password
    ELASTIC_USER     = var.elastic_user
  }
}
