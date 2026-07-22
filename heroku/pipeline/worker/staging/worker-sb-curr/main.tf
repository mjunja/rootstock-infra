# =============================================================================
# worker-sb-curr - Heroku Application
# =============================================================================
# Part of the "worker" pipeline, "staging" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "worker-sb-curr"
  pipeline_name  = "worker"
  pipeline_stage = "staging"
  stack          = "heroku-22"  # differs from the module default

  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).

  # No dyno formation exists on this app
  formations = {}

  # Non-sensitive config vars.
  # NOTE: this app has no DEFAULT_MONGODB set live; the module base adds
  # DEFAULT_MONGODB=ORMONGO on first apply.
  config_vars = {

  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {

  }
}
