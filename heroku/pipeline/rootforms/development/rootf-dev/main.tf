# =============================================================================
# rootf-dev - Heroku Application
# =============================================================================
# This configuration manages the rootf-dev Heroku app, which is part of
# the "rootforms" pipeline at the "development" stage.
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
resource "heroku_app" "rootf_dev" {
  name   = var.app_name
  region = var.region
  stack  = var.stack

  organization {
    name = var.team_name
  }

  config_vars = {
    BOTH_MONGOS             = var.both_mongos
    DBFieldId               = var.dbfield_id
    DEFAULT_MONGODB         = var.default_mongodb
    I_AM_ONEOFF             = var.i_am_oneoff
    LOG_LEVEL               = var.log_level
    ORMONGO_REGION          = var.ormongo_region
    Org_ID                  = var.org_id
    SFORCE_NAMESPACE        = var.sforce_namespace
    SOInvoice               = var.soinvoice
    SO_Number               = var.so_number
    SalesInvoiceFormula     = var.sales_invoice_formula
    SalesInvoiceNo          = var.sales_invoice_no
    USE_SINGLE_THREAD_MODEL = var.use_single_thread_model
    UniqueFiled             = var.unique_filed
    doc_mapped_field_names  = var.doc_mapped_field_names
    isLoging                = var.is_loging
    mapped_field_names      = var.mapped_field_names
    templateId              = var.template_id
  }

  sensitive_config_vars = {
    HEROKU_PASSWORD      = var.heroku_password
    HEROKU_USERNAME      = var.heroku_username
    MONGOLAB_URI         = var.mongolab_uri
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_RS_URL       = var.ormongo_rs_url
    ORMONGO_URL          = var.ormongo_url
    ORMONGO_USERNAME     = var.ormongo_username
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
    dburl                = var.dburl
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Pipeline Coupling - Development Stage
# -----------------------------------------------------------------------------
resource "heroku_pipeline_coupling" "rootf_dev" {
  app_id   = heroku_app.rootf_dev.id
  pipeline = data.heroku_pipeline.rootforms.id
  stage    = "development"
}

# -----------------------------------------------------------------------------
# Dyno Formation
# -----------------------------------------------------------------------------
resource "heroku_formation" "rfworker" {
  app_id   = heroku_app.rootf_dev.id
  type     = "rfworker"
  quantity = var.rfworker_dyno_quantity
  size     = var.rfworker_dyno_size

  depends_on = [heroku_app.rootf_dev]
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------

# Papertrail - Log Management
resource "heroku_addon" "papertrail" {
  app_id = heroku_app.rootf_dev.id
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
    app_name    = heroku_app.rootf_dev.name
    github_repo = var.github_repo
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      EXISTING=$(curl -sf \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.rootf_dev.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null)

      if echo "$EXISTING" | grep -q '"repo"'; then
        echo "GitHub already connected, skipping..."
      else
        curl -sf -X POST \
          "https://kolkrabbi.heroku.com/account/github/repo" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"app_id": "${heroku_app.rootf_dev.uuid}", "repo": "${var.github_repo}"}'
      fi
    EOT
  }

  depends_on = [heroku_app.rootf_dev]
}

# Step 2: Configure auto-deploy branch
resource "null_resource" "auto_deploy" {
  triggers = {
    app_name      = heroku_app.rootf_dev.name
    deploy_branch = var.deploy_branch
    auto_deploy   = var.auto_deploy
    wait_for_ci   = var.wait_for_ci
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      curl -sf -X PATCH \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.rootf_dev.uuid}/github" \
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

# NOTE: ormongo:2-mmap is billed to worker-rstk-dev
# and shared across many apps. Managed as attachment, not owned here.
#
# resource "heroku_addon_attachment" "ormongo" {
#   app_id   = heroku_app.rootf_dev.id
#   addon_id = "<ormongo-addon-id-from-worker-rstk-dev>"
#   name     = "ORMONGO"
# }
