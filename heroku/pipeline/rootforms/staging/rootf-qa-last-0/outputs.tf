# =============================================================================
# Outputs
# =============================================================================

output "app_id" {
  description = "The Heroku app ID"
  value       = heroku_app.rootf_qa_last_0.id
}

output "app_name" {
  description = "The Heroku app name"
  value       = heroku_app.rootf_qa_last_0.name
}

output "web_url" {
  description = "The web URL of the app"
  value       = heroku_app.rootf_qa_last_0.web_url
}

output "git_url" {
  description = "The Git URL for deploying to this app"
  value       = heroku_app.rootf_qa_last_0.git_url
}

output "heroku_hostname" {
  description = "The hostname for the app"
  value       = heroku_app.rootf_qa_last_0.heroku_hostname
}

output "pipeline_id" {
  description = "The pipeline this app belongs to"
  value       = data.heroku_pipeline.rootforms.id
}

output "pipeline_stage" {
  description = "The pipeline stage"
  value       = heroku_pipeline_coupling.rootf_qa_last_0.stage
}
