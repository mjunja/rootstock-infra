# CI workflows

## `validate.yml` — automatic

Runs on every PR / push to `main` touching `heroku/**`. Repo-wide `tofu fmt`
check plus `tofu validate` on each changed app folder (a change to
`heroku/modules/**` validates every app). Needs no secrets and never talks to
Heroku or a state backend.

## `stack-rollout.yml` — manual (workflow_dispatch)

Rolls out an already-committed stack change (or any app change) through:

```
plan  ->  approval gate  ->  apply  ->  rebuild latest commit on new stack
```

The **rebuild** step is what actually moves the dynos: a stack change via
tofu only sets the *build* stack, so the workflow purges the build cache and
recreates a build from the connected repo's current branch head — same commit
SHA, no new commit. Apps without GitHub integration get a warning and must be
rebuilt manually.

### Inputs

| Input | Meaning |
|---|---|
| `apps` | Apps to roll out, comma/space separated — full paths (`worker/staging/worker-rstk-qa`) or bare app names (`worker-rstk-qa`), resolved automatically |
| `mode` | `plan-only` (default) or `plan-and-apply` |
| `stack_only_guard` | Fail if the plan touches anything besides `heroku_app.stack` (default on) |
| `redeploy` | Rebuild after apply so the running stack matches (default on) |
| `allow_prod` | Must be explicitly set to include `…/production/…` apps; prod applies are also gated by the separate `heroku-infra-prod` environment |

After a successful rebuild, a **post-deploy health check** verifies the app
actually came up: latest release `succeeded` (catches release-phase
failures), all formation dynos reach `up` with none `crashed` (~3 min poll),
and the recent Logplex buffer is scanned for crash signatures (`State changed
from starting to crashed`, `Process exited with status N`, `Error R…`,
`OutOfMemoryError`, main-thread exceptions). It reads logs via a one-shot
log-session, so it works on apps with no log retention add-on. A failure
fails the run with a log excerpt in the summary — the manual brake is
`heroku rollback`, which reverts slug **and** stack.

### Canary-then-batch convention

1. Commit the stack change for the canary app only → run with that one app,
   `plan-and-apply`. Verify the OS-dependent paths (document rendering,
   fonts/UTF-8, barcodes) on the new stack.
2. Commit the change for the rest of the homogeneous fleet → run once with
   the batch: `worker/staging/worker-test-last-0, worker/staging/worker-test-last-1, …`

Applies run `max-parallel: 1` so a failing app stops the batch early.

### One-time setup

1. **Remote state per app.** Every app folder has a `backend "pg"` block
   (one `schema_name` per app). The backend is **INTERIM: grafana-stg's
   `heroku-postgresql:essential-0`** — tofu state lives in per-app schemas
   next to (but fully isolated from) Grafana's `public` schema. State is
   **client-side encrypted** (pbkdf2 + AES-GCM), so a reader of that
   database sees ciphertext only.

   - `PG_CONN_STR` = grafana-stg's `DATABASE_URL` + `?sslmode=require`.
     Heroku rotates it on some maintenance events — when auth starts
     failing, refresh from `heroku config:get DATABASE_URL -a grafana-stg`
     and update the secret + local `.env`.
   - `TF_ENCRYPTION` = the full encryption config (key provider +
     passphrase). Same value locally and in CI; also keep the passphrase in
     the team password manager — **losing it means re-importing state**.
   - Locally, both come from the repo-root `.env` (gitignored):
     `source .env` before running tofu.
   - Only apps that were actually applied/imported have state; the others'
     schemas appear when they are first managed. The workflow refuses to
     plan/apply any app whose remote state is empty — that guard is what
     prevents CI from trying to re-create live apps.
   - **Migration tripwire: move state to a dedicated Postgres before the
     first production app is codified.** The move is `PG_CONN_STR` change +
     `tofu init -migrate-state` per app; the passphrase travels unchanged.

2. **Environments** with *required reviewers* — the approval gate between
   plan and apply. Reviewers inspect the plan in the run's job summary
   before approving.
   - `heroku-infra` — dev/staging applies
   - `heroku-infra-prod` — production applies (stricter reviewer list);
     prod runs must ALSO pass the `allow_prod=true` input, so touching prod
     is always a double opt-in

3. **Repo secrets**

   | Secret | Purpose |
   |---|---|
   | `HEROKU_API_KEY` | Heroku API token (used by tofu, Kolkrabbi, builds API) |
   | `PG_CONN_STR` | Postgres connection string for the `pg` state backend (grafana-stg `DATABASE_URL` + `?sslmode=require`, interim) |
   | `TF_ENCRYPTION` | Full OpenTofu state-encryption config incl. passphrase (copy from local `.env`) |
   | `GH_REPOS_TOKEN` | Read access to app source repos (tarball download for rebuild) |
   | `TFVARS_<APP>` | Per-app: the full content of that app's `terraform.tfvars`. Name = app name uppercased, `-` → `_`, e.g. `worker-rstk-qa` → `TFVARS_WORKER_RSTK_QA` |

   The per-app tfvars secrets are required because plans evaluate
   `var.secrets["…"]` lookups — a missing map key fails the plan by design
   rather than silently unsetting a config var.

### Safety properties

- Plan files (which embed secret config var values) never leave the runner —
  the apply job re-plans and re-guards instead of downloading an artifact.
- `stack_only_guard` machine-checks that a "stack upgrade" plan is *only*
  a stack upgrade; drift or accidental bundled edits fail the run.
- `prevent_destroy` on every app (module-level) still applies underneath
  everything CI does.
- Emergency brake: `heroku rollback` reverts both the slug **and** the stack;
  afterwards revert the tofu commit too, or the next apply re-upgrades.
