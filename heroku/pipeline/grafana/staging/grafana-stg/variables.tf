# =============================================================================
# grafana-stg - Sensitive inputs
# =============================================================================
# Only the sensitive config vars are declared here. Everything else is set
# directly in main.tf or inherited from the rstk-app module defaults.
# Provide values via terraform.tfvars or TF_VAR_* environment variables.
#
# NOTE: addon-injected vars (CLOUDAMQP_APIKEY, CLOUDAMQP_URL, DATABASE_URL, FOUNDELASTICSEARCH_INITIAL_CREDENTIALS, FOUNDELASTICSEARCH_KIBANA, FOUNDELASTICSEARCH_URL, HEROKU_POSTGRESQL_GREEN_URL)
# are NOT declared or managed here.
# =============================================================================
