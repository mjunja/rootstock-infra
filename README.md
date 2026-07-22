# rootstock-infra

OpenTofu / Terraform configuration for Rootstock's Heroku applications.

## Layout

```
heroku/
├── modules/
│   └── rstk-app/              # Shared module: app + pipeline + dynos + addon + GitHub
└── apps/
    ├── finreport-rstk-dev/    # financials pipeline (development)
    ├── finreport-rstk-qa/     # financials pipeline (staging)
    ├── mrp-rstk-dev/          # mrp pipeline (development)
    └── mrp-rstk-qa/           # mrp pipeline (development)
```

Each app folder is a thin root module that calls `modules/rstk-app` with only
its app-specific values. Everything common is defined once in the module.

## Where to change common configuration

| Want to change… | Edit |
|---|---|
| region / stack / team for all apps | `heroku/modules/rstk-app/variables.tf` defaults |
| provider versions | `heroku/modules/rstk-app/versions.tf` |
| config vars shared by all apps (`DEFAULT_MONGODB`) | `heroku/modules/rstk-app/locals.tf` |
| GitHub auto-deploy / Kolkrabbi logic | `heroku/modules/rstk-app/main.tf` |
| one app's repo, branch, dynos, plan, config | that app's `apps/<name>/main.tf` |

## Usage

Per app directory:

```bash
export HEROKU_API_KEY="$(heroku auth:token)"   # or a long-lived token
cd heroku/apps/finreport-rstk-dev

cp terraform.tfvars.example terraform.tfvars    # then fill in the secrets
tofu init
tofu plan
tofu apply
```

Sensitive values (`ORMONGO_*`, `MONGOLAB_URI`, …) come from `terraform.tfvars`
(gitignored) or `TF_VAR_*` env vars — never committed.

## Adopting an app that already exists on Heroku

These configs describe live apps. The first time you manage one, import the
existing Heroku resources into Terraform state so no apply tries to recreate
them. Example for `finreport-rstk-dev`:

```bash
cd heroku/apps/finreport-rstk-dev
tofu init
tofu import 'module.app.heroku_app.this'                    finreport-rstk-dev
tofu import 'module.app.heroku_pipeline_coupling.this'      <coupling-id>          # UUID
tofu import 'module.app.heroku_formation.this["newoneoff"]' finreport-rstk-dev:newoneoff  # app:type (colon!)
tofu import 'module.app.heroku_addon.papertrail[0]'         <addon-id>             # UUID
tofu plan   # confirm: no changes (or only expected drift)
```

`null_resource`s for GitHub wiring cannot be imported; on first apply they run
their idempotent scripts (which skip if GitHub is already connected).

## State migration (existing apps refactored into the module)

`mrp-rstk-dev` and `mrp-rstk-qa` were refactored from standalone resources into
`module.app`. Each has a `moved.tf` mapping the old addresses to the new module
addresses, so `tofu plan` shows the move as a no-op (no destroy/recreate) for
any existing state. The `moved` blocks can be deleted once every environment has
applied the move.

## Notes

- State is currently local (`terraform.tfstate`, gitignored). The S3 backend is
  scaffolded but commented out in each app's `providers.tf`.
- `prevent_destroy = true` is set on every app — applies cannot delete an app.
- Postgres and ORMongo are shared add-ons billed to owner apps
  (`mrp-rstk-prod`, `worker-rstk-dev`) and attached, not created here.
