# =============================================================================
# MRP RSTK QA - Heroku Application
# =============================================================================
# This configuration manages the mrp-rstk-qa Heroku app, which is part of
# the "mrp" pipeline at the "development" stage.
#
# Pipeline: mrp
#   development: mrp-rstk-dev, mrp-rstk-qa (this app)
#   staging:     mrp-rstk-test, mrp-spectra-test
#   production:  mrp-rstk-prod, mrp-prod, mrp-spectra-prod
# =============================================================================

# -----------------------------------------------------------------------------
# Data: Import existing pipeline
# -----------------------------------------------------------------------------
data "heroku_pipeline" "mrp" {
  name = "mrp"
}

# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
resource "heroku_app" "mrp_rstk_qa" {
  name   = var.app_name
  region = var.region
  stack  = var.stack

  organization {
    name = var.team_name
  }

  config_vars = {
    APP_NAME          = var.app_config_name
    DEFAULT_MONGODB   = var.default_mongodb
    JAVA_OPTS         = var.java_opts
    LOGSTASH_URL      = var.logstash_url
    NO_NAMESPACE_ORGS = var.no_namespace_orgs
    PGCLIENTENCODING  = var.pgclient_encoding
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
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Pipeline Coupling - Development Stage
# -----------------------------------------------------------------------------
resource "heroku_pipeline_coupling" "mrp_rstk_qa" {
  app_id   = heroku_app.mrp_rstk_qa.id
  pipeline = data.heroku_pipeline.mrp.id
  stage    = "development"
}

# -----------------------------------------------------------------------------
# Dyno Formation
# -----------------------------------------------------------------------------
resource "heroku_formation" "dashboard" {
  app_id   = heroku_app.mrp_rstk_qa.id
  type     = "dashboard"
  quantity = var.dashboard_dyno_quantity
  size     = var.dashboard_dyno_size

  depends_on = [heroku_app.mrp_rstk_qa]
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------

# Papertrail - Log Management
resource "heroku_addon" "papertrail" {
  app_id = heroku_app.mrp_rstk_qa.id
  plan   = "papertrail:fixa"
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
    app_name    = heroku_app.mrp_rstk_qa.name
    github_repo = var.github_repo
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      EXISTING=$(curl -sf \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.mrp_rstk_qa.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null)

      if echo "$EXISTING" | grep -q '"repo"'; then
        echo "GitHub already connected, skipping..."
      else
        curl -sf -X POST \
          "https://kolkrabbi.heroku.com/account/github/repo" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"app_id": "${heroku_app.mrp_rstk_qa.uuid}", "repo": "${var.github_repo}"}'
      fi
    EOT
  }

  depends_on = [heroku_app.mrp_rstk_qa]
}

# Step 2: Configure auto-deploy branch
resource "null_resource" "auto_deploy" {
  triggers = {
    app_name      = heroku_app.mrp_rstk_qa.name
    deploy_branch = var.deploy_branch
    auto_deploy   = var.auto_deploy
    wait_for_ci   = var.wait_for_ci
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      curl -sf -X PATCH \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.mrp_rstk_qa.uuid}/github" \
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
# and shared across many apps. Managed as attachment, not owned here.
#
# resource "heroku_addon_attachment" "database" {
#   app_id   = heroku_app.mrp_rstk_qa.id
#   addon_id = "<postgresql-addon-id-from-mrp-rstk-prod>"
#   name     = "DATABASE"
# }

# NOTE: ormongo:2-mmap is billed to worker-rstk-dev
# and shared across many apps. Managed as attachment, not owned here.
#
# resource "heroku_addon_attachment" "ormongo" {
#   app_id   = heroku_app.mrp_rstk_qa.id
#   addon_id = "<ormongo-addon-id-from-worker-rstk-dev>"
#   name     = "ORMONGO"
# }
