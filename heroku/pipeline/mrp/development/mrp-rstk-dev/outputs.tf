# =============================================================================
# mrp-rstk-dev - Outputs (re-exported from the module)
# =============================================================================

output "app_id" {
  description = "The Heroku app ID"
  value       = module.app.app_id
}

output "app_name" {
  description = "The Heroku app name"
  value       = module.app.app_name
}

output "web_url" {
  description = "The web URL of the app"
  value       = module.app.web_url
}

output "git_url" {
  description = "The Git URL for deploying to this app"
  value       = module.app.git_url
}

output "heroku_hostname" {
  description = "The hostname for the app"
  value       = module.app.heroku_hostname
}

output "pipeline_id" {
  description = "The pipeline this app belongs to"
  value       = module.app.pipeline_id
}

output "pipeline_stage" {
  description = "The pipeline stage"
  value       = module.app.pipeline_stage
}
