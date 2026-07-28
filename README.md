# rootstock-infra

OpenTofu / Terraform configuration for Rootstock's Heroku applications.

Everything here **mirrors the live Heroku apps** — configs are codified from
production reality, and nothing changes on Heroku until you deliberately run
`tofu apply`.

## Layout

```
heroku/
├── modules/
│   └── rstk-app/                  # THE shared module: app + pipeline coupling
│                                  # + formations + owned add-ons + GitHub wiring
└── pipeline/                      # mirrors the Heroku dashboard hierarchy
    └── <pipeline>/                # mrp, financials, rootforms, stdcosts,
        └── <stage>/               # worker, web, grafana, rootstock-logstash…
            └── <app>/             # one thin root module per app
tools/
└── codify_app.py                  # generates an app folder from live Heroku
```

Each app folder is a thin root module calling `modules/rstk-app` with only
that app's specifics. Every app folder has the same six files:

| File | Committed | Purpose |
|---|---|---|
| `main.tf` | yes | module call mirroring the live app |
| `variables.tf` | yes | one sensitive `secrets` map variable |
| `outputs.tf` | yes | re-exports of the module outputs |
| `providers.tf` | yes | provider requirements + backend placeholder |
| `terraform.tfvars.example` | yes | blank template listing the secret keys |
| `terraform.tfvars` | **no** (gitignored) | real secret values, local only |

## Where to change common configuration

| Want to change… | Edit |
|---|---|
| region / stack / team for all apps | `heroku/modules/rstk-app/variables.tf` defaults |
| provider versions | `heroku/modules/rstk-app/versions.tf` |
| config vars shared by all apps (`DEFAULT_MONGODB`) | `heroku/modules/rstk-app/locals.tf` |
| GitHub auto-deploy / Kolkrabbi logic | `heroku/modules/rstk-app/main.tf` |
| one app's repo, branch, dynos, add-ons, config | that app's `main.tf` |
| one app's secret values | that app's `terraform.tfvars` (local) |

## Adding an app

```bash
python3 tools/codify_app.py <pipeline> <stage> <app>
# e.g.
python3 tools/codify_app.py rootforms staging rootf-test
```

The tool reads the live app (read-only GETs), classifies its config vars
(plain / sensitive / addon-injected), and writes the whole app folder —
including a local gitignored `terraform.tfvars` with the real secret values.

## Usage

```bash
export HEROKU_API_KEY="$(heroku auth:token)"
cd heroku/pipeline/<pipeline>/<stage>/<app>

tofu init
tofu plan          # read-only; nothing changes on Heroku without apply
```

## Adopting an app that already exists on Heroku

These configs describe live apps. Apps codified but never applied have no
local state — a `plan` there proposes *creating* resources that already
exist. Before actively managing one, import the live resources:

```bash
cd heroku/pipeline/financials/development/finreport-rstk-dev
tofu init
tofu import 'module.app.heroku_app.this'                    finreport-rstk-dev
tofu import 'module.app.heroku_pipeline_coupling.this'      <coupling-id>          # UUID
tofu import 'module.app.heroku_formation.this["newoneoff"]' finreport-rstk-dev:newoneoff  # app:type
tofu import 'module.app.heroku_addon.this["papertrail"]'    <addon-id>             # UUID
tofu plan   # confirm: no changes (or only expected drift)
```

`null_resource`s for GitHub wiring cannot be imported; on first apply they run
their idempotent scripts (which skip if GitHub is already connected).

## State migration notes

- `mrp-rstk-dev` / `mrp-rstk-qa` were refactored from standalone resources
  into `module.app`; each keeps a `moved.tf` mapping old state addresses to
  the module. The module itself also carries `moved` blocks for its own
  refactors (papertrail → `addons` map, optional GitHub wiring). Chained
  moves resolve in one plan; the blocks can be deleted once every
  environment has applied them.

## Conventions

- **Production apps are not codified** (deliberate).
- State is remote: `pg` backend, one schema per app, **client-side
  encrypted** — INTERIM home is grafana-stg's postgres until a dedicated
  instance exists (must move before any production app is codified).
  `source .env` (gitignored) for `PG_CONN_STR` + `TF_ENCRYPTION`, or see
  `.github/README.md`. Leftover local `terraform.tfstate` files are
  pre-migration backups.
- `prevent_destroy = true` on every app — applies cannot delete an app.
- Add-ons **owned** by an app go in its `addons` map; add-ons **billed to
  another app** (shared Postgres, ORMongo, CloudAMQP) are attached, never
  created here — only documented in comments.
- Config vars **injected by attached add-ons** (`ORMONGO_URL`,
  `PAPERTRAIL_API_TOKEN`, `DATABASE_URL`, `CLOUDAMQP_*`,
  `FOUNDELASTICSEARCH_*`, …) are never managed — the platform owns them.
  Classification is per app: the same var can be injected on one app and a
  managed secret on another.
- Secrets live only in gitignored `terraform.tfvars` files as one
  `secrets = { KEY = "value" }` map per app.
