# =============================================================================
# MRP RSTK Dev - Heroku Application
# =============================================================================
# This configuration manages the mrp-rstk-dev Heroku app, which is part of
# the "mrp" pipeline at the "development" stage.
#
# Pipeline: mrp
#   development: mrp-rstk-dev (this app), mrp-rstk-qa
#   staging:     mrp-rstk-test, mrp-spectra-test
#   production:  mrp-rstk-prod, mrp-prod, mrp-spectra-prod
# =============================================================================

# -----------------------------------------------------------------------------
# Data: Import existing pipeline (managed separately or already exists)
# -----------------------------------------------------------------------------
data "heroku_pipeline" "mrp" {
  name = "mrp"
}

# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
resource "heroku_app" "mrp_rstk_dev" {
  name   = var.app_name
  region = var.region
  stack  = var.stack

  organization {
    name = var.team_name
  }

  config_vars = {
    APP_NAME         = var.app_config_name
    DEBUG_PEITEMID   = var.debug_peitemid
    DEFAULT_MONGODB  = var.default_mongodb
    JAVA_OPTS        = var.java_opts
    LOGSTASH_URL     = var.logstash_url
    NO_NAMESPACE_ORGS = var.no_namespace_orgs
    PGCLIENTENCODING = var.pgclient_encoding
  }

  sensitive_config_vars = {
    ORMONGO_DBNAME   = var.ormongo_dbname
    ORMONGO_PASSWORD = var.ormongo_password
    ORMONGO_REGION   = var.ormongo_region
    ORMONGO_RS_URL   = var.ormongo_rs_url
    ORMONGO_URL      = var.ormongo_url
    ORMONGO_USERNAME = var.ormongo_username
  }

  lifecycle {
    # Prevent accidental destruction of the app
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Pipeline Coupling - Development Stage
# -----------------------------------------------------------------------------
resource "heroku_pipeline_coupling" "mrp_rstk_dev" {
  app_id   = heroku_app.mrp_rstk_dev.id
  pipeline = data.heroku_pipeline.mrp.id
  stage    = "development"
}

# -----------------------------------------------------------------------------
# Dyno Formation
# -----------------------------------------------------------------------------
resource "heroku_formation" "dashboard" {
  app_id   = heroku_app.mrp_rstk_dev.id
  type     = "dashboard"
  quantity = var.dashboard_dyno_quantity
  size     = var.dashboard_dyno_size

  depends_on = [heroku_app.mrp_rstk_dev]
}

resource "heroku_formation" "myworker" {
  app_id   = heroku_app.mrp_rstk_dev.id
  type     = "myworker"
  quantity = var.myworker_dyno_quantity
  size     = var.myworker_dyno_size

  depends_on = [heroku_app.mrp_rstk_dev]
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------

# Papertrail - Log Management
resource "heroku_addon" "papertrail" {
  app_id = heroku_app.mrp_rstk_dev.id
  plan   = "papertrail:ludvig"
}

# -----------------------------------------------------------------------------
# GitHub Integration & Auto-Deploy Branch
# -----------------------------------------------------------------------------
# The Heroku provider does not support GitHub integration natively.
# We use null_resource + Heroku Kolkrabbi API to manage it.
# -----------------------------------------------------------------------------

# Step 1: Connect GitHub repo to Heroku app (idempotent - skips if already connected)
resource "null_resource" "github_connect" {
  triggers = {
    app_name    = heroku_app.mrp_rstk_dev.name
    github_repo = var.github_repo
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get token from HEROKU_API_KEY or fall back to heroku CLI
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      # Check if GitHub is already connected
      EXISTING=$(curl -sf \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.mrp_rstk_dev.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null)

      if echo "$EXISTING" | grep -q '"repo"'; then
        echo "GitHub already connected, skipping..."
      else
        curl -sf -X POST \
          "https://kolkrabbi.heroku.com/account/github/repo" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"app_id": "${heroku_app.mrp_rstk_dev.uuid}", "repo": "${var.github_repo}"}'
      fi
    EOT
  }

  depends_on = [heroku_app.mrp_rstk_dev]
}

# Step 2: Configure auto-deploy branch (idempotent - always applies desired state)
resource "null_resource" "auto_deploy" {
  triggers = {
    app_name      = heroku_app.mrp_rstk_dev.name
    deploy_branch = var.deploy_branch
    auto_deploy   = var.auto_deploy
    wait_for_ci   = var.wait_for_ci
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get token from HEROKU_API_KEY or fall back to heroku CLI
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      curl -sf -X PATCH \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.mrp_rstk_dev.uuid}/github" \
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

# NOTE: heroku-postgresql:standard-2 is billed to mrp-rstk-prod
# and shared across many apps via addon attachments.
# It should be managed in the mrp-rstk-prod configuration,
# then attached here using heroku_addon_attachment.
#
# resource "heroku_addon_attachment" "database" {
#   app_id  = heroku_app.mrp_rstk_dev.id
#   addon_id = "<postgresql-addon-id-from-mrp-rstk-prod>"
#   name     = "DATABASE"
# }

# NOTE: ormongo:2-mmap is billed to worker-rstk-dev
# and shared across many apps via addon attachments.
# It should be managed in the worker-rstk-dev configuration,
# then attached here using heroku_addon_attachment.
#
# resource "heroku_addon_attachment" "ormongo" {
#   app_id  = heroku_app.mrp_rstk_dev.id
#   addon_id = "<ormongo-addon-id-from-worker-rstk-dev>"
#   name     = "ORMONGO"
# }
