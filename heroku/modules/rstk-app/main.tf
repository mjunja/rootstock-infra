# =============================================================================
# rstk-app module - Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Data: existing pipeline (managed separately / already exists)
# -----------------------------------------------------------------------------
data "heroku_pipeline" "this" {
  name = var.pipeline_name
}

# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
resource "heroku_app" "this" {
  name   = var.app_name
  region = var.region
  stack  = var.stack

  organization {
    name = var.team_name
  }

  config_vars           = local.config_vars
  sensitive_config_vars = var.sensitive_config_vars

  lifecycle {
    # Prevent accidental destruction of the app. prevent_destroy must be a
    # literal (it cannot reference a variable), so it is on for every app.
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Pipeline coupling
# -----------------------------------------------------------------------------
resource "heroku_pipeline_coupling" "this" {
  app_id   = heroku_app.this.id
  pipeline = data.heroku_pipeline.this.id
  stage    = var.pipeline_stage
}

# -----------------------------------------------------------------------------
# Dyno formation (one heroku_formation per process type)
# -----------------------------------------------------------------------------
resource "heroku_formation" "this" {
  for_each = var.formations

  app_id   = heroku_app.this.id
  type     = each.key
  quantity = each.value.quantity
  size     = each.value.size

  depends_on = [heroku_app.this]
}

# -----------------------------------------------------------------------------
# Add-ons
# -----------------------------------------------------------------------------

# Papertrail - Log Management (only when a plan is provided)
resource "heroku_addon" "papertrail" {
  count = var.papertrail_plan == null ? 0 : 1

  app_id = heroku_app.this.id
  plan   = var.papertrail_plan
}

# -----------------------------------------------------------------------------
# GitHub Integration & Auto-Deploy Branch
# -----------------------------------------------------------------------------
# The Heroku provider does not support GitHub integration natively.
# We use null_resource + Heroku Kolkrabbi API to manage it.
# -----------------------------------------------------------------------------

# Step 1: Connect GitHub repo to Heroku app (idempotent - skips if already connected)
resource "null_resource" "github_connect" {
  count = var.github_repo == null ? 0 : 1

  triggers = {
    app_name    = heroku_app.this.name
    github_repo = var.github_repo
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get token from HEROKU_API_KEY or fall back to heroku CLI
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      # Check if GitHub is already connected
      EXISTING=$(curl -sf \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.this.uuid}/github" \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null)

      if echo "$EXISTING" | grep -q '"repo"'; then
        echo "GitHub already connected, skipping..."
      else
        curl -sf -X POST \
          "https://kolkrabbi.heroku.com/account/github/repo" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"app_id": "${heroku_app.this.uuid}", "repo": "${var.github_repo}"}'
      fi
    EOT
  }

  depends_on = [heroku_app.this]
}

# Step 2: Configure auto-deploy branch (idempotent - always applies desired state)
resource "null_resource" "auto_deploy" {
  count = var.github_repo == null ? 0 : 1

  triggers = {
    app_name      = heroku_app.this.name
    deploy_branch = var.deploy_branch
    auto_deploy   = var.auto_deploy
    wait_for_ci   = var.wait_for_ci
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get token from HEROKU_API_KEY or fall back to heroku CLI
      TOKEN="$${HEROKU_API_KEY:-$(heroku auth:token 2>/dev/null)}"

      curl -sf -X PATCH \
        "https://kolkrabbi.heroku.com/apps/${heroku_app.this.uuid}/github" \
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

# GitHub wiring gained `count` when it became optional; keep existing state
# addresses valid for apps applied before that change.
moved {
  from = null_resource.github_connect
  to   = null_resource.github_connect[0]
}

moved {
  from = null_resource.auto_deploy
  to   = null_resource.auto_deploy[0]
}

# -----------------------------------------------------------------------------
# Shared add-ons billed to OTHER apps (Postgres, ORMongo)
# -----------------------------------------------------------------------------
# heroku-postgresql and ormongo are billed to owner apps (e.g. mrp-rstk-prod,
# worker-rstk-dev) and shared across many apps via addon attachments. They are
# NOT created here. If/when you want Terraform to manage the attachment, add a
# heroku_addon_attachment in the owner app's config and reference its addon id:
#
#   resource "heroku_addon_attachment" "database" {
#     app_id   = heroku_app.this.id
#     addon_id = "<postgresql-addon-id-from-owner-app>"
#     name     = "DATABASE"
#   }
