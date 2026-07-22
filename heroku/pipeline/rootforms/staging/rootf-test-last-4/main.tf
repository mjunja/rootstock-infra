# =============================================================================
# rootf-test-last-4 - Heroku Application
# =============================================================================
# This configuration manages the rootf-test-last-4 Heroku app, which is part of
# the "rootforms" pipeline at the "staging" stage.
#
# Pipeline: rootforms
#   development: rootf-dev, rootf-qa
#   staging:     rootf-qa-last-0, rootf-test, rootf-test-last-0..5
#   production:  rootf-prod, rootf-prod-last-0..5 (not managed here)
# =============================================================================

# -----------------------------------------------------------------------------
# Data: Import existing pipeline
# -----------------------------------------------------------------------------
data "heroku_pipeline" "rootforms" {
  name = "rootforms"
}

# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
resource "heroku_app" "rootf_test_last_4" {
  name   = var.app_name
  region = var.region
  stack  = var.stack

  organization {
    name = var.team_name
  }

  config_vars = {
    DEFAULT_MONGODB     = var.default_mongodb
    ORMONGO_REGION      = var.ormongo_region
    SFORCE_NAMESPACE    = var.sforce_namespace
    SFORCE_REDIRECT_URL = var.sforce_redirect_url
    supportedLocale     = var.supported_locale
  }

  sensitive_config_vars = {
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_RS_URL       = var.ormongo_rs_url
    ORMONGO_URL          = var.ormongo_url
    ORMONGO_USERNAME     = var.ormongo_username
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Pipeline Coupling - Staging Stage
# -----------------------------------------------------------------------------
resource "heroku_pipeline_coupling" "rootf_test_last_4" {
  app_id   = heroku_app.rootf_test_last_4.id
  pipeline = data.heroku_pipeline.rootforms.id
  stage    = "staging"
}

# -----------------------------------------------------------------------------
# Dyno Formation
# -----------------------------------------------------------------------------
resource "heroku_formation" "rfworker" {
  app_id   = heroku_app.rootf_test_last_4.id
  type     = "rfworker"
  quantity = var.rfworker_dyno_quantity
  size     = var.rfworker_dyno_size

  depends_on = [heroku_app.rootf_test_last_4]
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------

# Papertrail - Log Management
resource "heroku_addon" "papertrail" {
  app_id = heroku_app.rootf_test_last_4.id
  plan   = "papertrail:choklad"
}

# -----------------------------------------------------------------------------
# GitHub Integration & Auto-Deploy Branch
# -----------------------------------------------------------------------------
# The Heroku provider does not support GitHub integration natively.
# We use null_resource + Heroku Kolkrabbi API to manage it.
# -----------------------------------------------------------------------------

# Step 1: Connect GitHub repo to Heroku app (idempotent)
resource "null_resource" "github_connect" {
  triggers = {
    app_name    = heroku_app.rootf_test_last_4.name
    github_repo = var.github_repo
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      EXISTING=$(curl -sf \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.rootf_test_last_4.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null)

      if echo "$EXISTING" | grep -q '"repo"'; then
        echo "GitHub already connected, skipping..."
      else
        curl -sf -X POST \
          "https://kolkrabbi.heroku.com/account/github/repo" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"app_id": "${heroku_app.rootf_test_last_4.uuid}", "repo": "${var.github_repo}"}'
      fi
    EOT
  }

  depends_on = [heroku_app.rootf_test_last_4]
}

# Step 2: Configure auto-deploy branch
resource "null_resource" "auto_deploy" {
  triggers = {
    app_name      = heroku_app.rootf_test_last_4.name
    deploy_branch = var.deploy_branch
    auto_deploy   = var.auto_deploy
    wait_for_ci   = var.wait_for_ci
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      curl -sf -X PATCH \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.rootf_test_last_4.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "auto_deploy": ${var.auto_deploy},
          "wait_for_ci": ${var.wait_for_ci},
          "branch": "${var.deploy_branch}"
        }'
    EOT
  }

  depends_on = [null_resource.github_connect]
}

# NOTE: ormongo:2-mmap is billed to worker-rstk-test
# and shared across many apps. Managed as attachment, not owned here.
#
# resource "heroku_addon_attachment" "ormongo" {
#   app_id   = heroku_app.rootf_test_last_4.id
#   addon_id = "<ormongo-addon-id-from-worker-rstk-test>"
#   name     = "ORMONGO"
# }
