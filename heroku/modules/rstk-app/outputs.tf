# =============================================================================
# rstk-app module - Outputs
# =============================================================================

output "app_id" {
  description = "The Heroku app ID"
  value       = heroku_app.this.id
}

output "app_name" {
  description = "The Heroku app name"
  value       = heroku_app.this.name
}

output "app_uuid" {
  description = "The Heroku app UUID"
  value       = heroku_app.this.uuid
}

output "web_url" {
  description = "The web URL of the app"
  value       = heroku_app.this.web_url
}

output "git_url" {
  description = "The Git URL for deploying to this app"
  value       = heroku_app.this.git_url
}

output "heroku_hostname" {
  description = "The hostname for the app"
  value       = heroku_app.this.heroku_hostname
}

output "pipeline_id" {
  description = "The pipeline this app belongs to"
  value       = data.heroku_pipeline.this.id
}

output "pipeline_stage" {
  description = "The pipeline stage"
  value       = heroku_pipeline_coupling.this.stage
}
