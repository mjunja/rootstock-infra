# =============================================================================
# State migration: standalone resources -> rstk-app module
# =============================================================================
# These `moved` blocks tell Terraform/OpenTofu that resources previously
# declared directly in this app were relocated into module.app. They make the
# refactor a no-op against existing state (no destroy/recreate). Safe to keep
# even if this app has never been applied.
# =============================================================================

moved {
  from = heroku_app.mrp_rstk_qa
  to   = module.app.heroku_app.this
}

moved {
  from = heroku_pipeline_coupling.mrp_rstk_qa
  to   = module.app.heroku_pipeline_coupling.this
}

moved {
  from = heroku_formation.dashboard
  to   = module.app.heroku_formation.this["dashboard"]
}

moved {
  from = heroku_addon.papertrail
  to   = module.app.heroku_addon.papertrail[0]
}

moved {
  from = null_resource.github_connect
  to   = module.app.null_resource.github_connect
}

moved {
  from = null_resource.auto_deploy
  to   = module.app.null_resource.auto_deploy
}
