# rstk-app module

Reusable module for a Rootstock Heroku app. Encapsulates everything common
across our apps so each app folder only declares what is unique to it.

## What it manages

- `heroku_app` (with `prevent_destroy`)
- `heroku_pipeline_coupling` (looks up an existing pipeline by name)
- `heroku_formation` — one per process type, driven by the `formations` map
- `heroku_addon` — Papertrail (optional, via `papertrail_plan`)
- GitHub auto-deploy wiring via the Kolkrabbi API (two `null_resource`s)

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
  source = "../../modules/rstk-app"

  app_name      = "my-app"
  pipeline_name = "financials"
  github_repo   = "rootstockmfg/my-repo"
  deploy_branch = "main"

  papertrail_plan = "papertrail:choklad"

  formations = {
    web = { size = "standard-1x", quantity = 1 }
  }

  config_vars = {
    JAVA_OPTS = "-XX:+UseG1GC -Xmx8g -Xms1g"
  }

  sensitive_config_vars = {
    ORMONGO_PASSWORD = var.ormongo_password
  }
}
```

## Notes

- **Addon-injected config vars** (e.g. `DATABASE_URL`, `ORMONGO_URL`,
  `PAPERTRAIL_API_TOKEN`) must NOT be passed in `config_vars` — the attached
  add-ons set them. Managing them here would fight the platform.
- `prevent_destroy` is a literal `true` (Terraform forbids referencing a
  variable there), so it is on for every app built from this module.
- Shared Postgres / ORMongo add-ons are billed to owner apps and attached, not
  created here — see the note at the bottom of `main.tf`.
