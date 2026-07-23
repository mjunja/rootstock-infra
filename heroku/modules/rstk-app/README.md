# rstk-app module

Reusable module for a Rootstock Heroku app. Encapsulates everything common
across our apps so each app folder only declares what is unique to it.

## What it manages

- `heroku_app` (with `prevent_destroy`)
- `heroku_pipeline_coupling` (looks up an existing pipeline by name)
- `heroku_formation` — one per process type, driven by the `formations` map
- `heroku_addon` — one per entry in the `addons` map (papertrail, ormongo,
  cloudamqp, … whatever the app OWNS)
- GitHub auto-deploy wiring via the Kolkrabbi API (two `null_resource`s) —
  optional: skipped entirely when `github_repo` is null

## Where common config lives

| Common thing | Location | Change it here to affect every app |
|---|---|---|
| region, stack, team | `variables.tf` defaults | yes |
| provider versions | `versions.tf` | yes |
| `DEFAULT_MONGODB` | `locals.tf` (`base_config_vars`) | yes |
| GitHub / Kolkrabbi logic | `main.tf` | yes |

`base_config_vars` is merged **under** each app's `config_vars`, so an app can
still override a shared value by setting the same key.

## Usage

```hcl
module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "my-app"
  pipeline_name  = "financials"
  pipeline_stage = "staging"          # defaults to "development"

  # GitHub integration - omit entirely for apps with no GitHub connection
  github_repo   = "rootstockmfg/my-repo"
  deploy_branch = "main"
  auto_deploy   = true

  # Add-ons OWNED by this app (service name => plan)
  addons = {
    papertrail = "papertrail:choklad"
    ormongo    = "ormongo:2-mmap"
  }

  formations = {
    web = { size = "standard-1x", quantity = 1 }
  }

  config_vars = {
    JAVA_OPTS = "-XX:+UseG1GC -Xmx8g -Xms1g"
  }

  # Values come from the app's `secrets` map variable (terraform.tfvars).
  # Explicit lookups fail loudly at plan time if a key is missing.
  sensitive_config_vars = {
    ORMONGO_PASSWORD = var.secrets["ORMONGO_PASSWORD"]
  }
}
```

## Notes

- **Addon-injected config vars** (e.g. `DATABASE_URL`, `ORMONGO_URL`,
  `PAPERTRAIL_API_TOKEN`, `CLOUDAMQP_*`) must NOT be passed in `config_vars`
  or `sensitive_config_vars` — the attached add-ons set them. Managing them
  here would fight the platform.
- `prevent_destroy` is a literal `true` (Terraform forbids referencing a
  variable there), so it is on for every app built from this module.
- Add-ons billed to OTHER apps and shared via attachments are not created
  here — see the note at the bottom of `main.tf`.
- The module carries `moved` blocks for its own refactor history
  (`papertrail_plan` → `addons` map; GitHub wiring gaining `count`), so
  state created under older versions migrates cleanly on the next plan.
