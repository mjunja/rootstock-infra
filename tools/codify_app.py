#!/usr/bin/env python3
"""Codify a live Heroku app into an OpenTofu root module under heroku/pipeline/.

Reads the app's live settings via the Heroku CLI / Platform API / Kolkrabbi
(read-only GETs - nothing is ever changed on Heroku) and emits a thin root
module that calls modules/rstk-app:

    heroku/pipeline/<pipeline>/<stage>/<app>/
        main.tf                  module call mirroring the live app
        variables.tf             a single sensitive `secrets` map variable
        outputs.tf               re-exports of the module outputs
        providers.tf             provider requirements + backend placeholder
        terraform.tfvars         real secret values   (gitignored - local only)
        terraform.tfvars.example blank template       (committed)

Usage:
    python3 tools/codify_app.py <pipeline> <stage> <app> [--repo-root DIR]

Example:
    python3 tools/codify_app.py rootforms staging rootf-test

Classification rules:
- Config vars matching SENSITIVE (or *_dbname) become entries in the
  `secrets` map, wired through sensitive_config_vars.
- Vars injected by add-ons attached to the app (ormongo, papertrail,
  cloudamqp, heroku-postgresql, foundelasticsearch) are NOT managed at all;
  they are listed in a comment. The same var can be a managed secret on one
  app and injected on another - classification is per app.
- DEFAULT_MONGODB=ORMONGO comes from the module base and is omitted; any
  other value is kept as an explicit override.
- Add-ons billed to THIS app go into the module's `addons` map; add-ons
  billed to other apps are documented, never created.
"""
import argparse, json, os, re, subprocess, sys, urllib.request

SENSITIVE = {
    "API_USN", "API_USNKY", "APPS_CLIENT_KEY", "APPS_CLIENT_SECRET", "BONSAI_URL",
    "CLOUDAMQP_APIKEY", "CLOUDAMQP_URL", "DATABASE_URL", "ELASTIC_PASSWORD",
    "ELASTIC_USER", "HEROKU_PASSWORD", "HEROKU_USERNAME", "MAVEN_REPO_PASSWORD",
    "MONGOLAB_URI", "ORMONGO_DBNAME", "ORMONGO_PASSWORD", "ORMONGO_USERNAME",
    "RSTK_KEY", "SFORCE_CLIENT_KEY", "SFORCE_CLIENT_SECRET", "dburl", "dburl1",
}

def is_sensitive(key):
    return key in SENSITIVE or key.endswith("_dbname")

def sh(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout

def api_get(url, token):
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.heroku+json; version=3",
    })
    try:
        with urllib.request.urlopen(req) as r:
            return json.load(r)
    except Exception:
        return {}

def hcl_key(k):
    return k if re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', k) else f'"{k}"'

def hcl_str(v):
    v = v.replace('\\', '\\\\').replace('"', '\\"').replace('${', '$${').replace('%{', '%%{')
    return '"' + v.replace('\r\n', '\\n').replace('\n', '\\n') + '"'

def fetch(app):
    token = os.environ.get("HEROKU_API_KEY") or sh(["heroku", "auth:token"]).strip()
    info = json.loads(sh(["heroku", "apps:info", "-a", app, "--json"]))
    cfg = json.loads(sh(["heroku", "config", "-a", app, "--json"]))
    fm = api_get(f"https://api.heroku.com/apps/{app}/formation", token)
    gh = api_get(f"https://kolkrabbi.heroku.com/apps/{info['app']['id']}/github", token)
    return info, cfg, fm, gh

def classify_injected(info, cfg):
    """Vars set by add-ons attached to this app -> {var: provenance comment}."""
    app = info["app"]["name"]
    injected = {}
    for ad in info.get("addons", []):
        svc = ad["addon_service"]["name"]
        billed = ad.get("billing_entity", {}).get("name")
        tag = f"{svc} (owned by this app)" if billed == app else f"{svc} (billed to {billed})"
        if svc == "ormongo":
            for k in ("ORMONGO_URL", "ORMONGO_RS_URL", "ORMONGO_REGION"):
                injected[k] = tag
        elif svc == "papertrail":
            injected["PAPERTRAIL_API_TOKEN"] = tag
        elif svc == "heroku-postgresql":
            injected["DATABASE_URL"] = tag
            for k in cfg:
                if re.match(r'^HEROKU_POSTGRESQL_\w+_URL$', k):
                    injected[k] = tag
        elif svc == "cloudamqp":
            injected["CLOUDAMQP_URL"] = tag
            injected["CLOUDAMQP_APIKEY"] = tag
        elif svc == "foundelasticsearch":
            for k in cfg:
                if k.startswith("FOUNDELASTICSEARCH_"):
                    injected[k] = tag
    return injected

def emit(pipeline, stage, app, repo_root):
    info, cfg, fm, gh = fetch(app)
    stack = info["app"]["stack"]["name"]
    owned = {ad["addon_service"]["name"]: ad["plan"]["name"]
             for ad in info.get("addons", [])
             if ad.get("billing_entity", {}).get("name") == app}
    shared = [(ad["addon_service"]["name"], ad["plan"]["name"],
               ad.get("billing_entity", {}).get("name"))
              for ad in info.get("addons", [])
              if ad.get("billing_entity", {}).get("name") != app]

    injected = classify_injected(info, cfg)
    injected_present = sorted(k for k in cfg if k in injected)
    secret = sorted(k for k in cfg if is_sensitive(k) and k not in injected)
    plain = {k: v for k, v in sorted(cfg.items())
             if not is_sensitive(k) and k not in injected}

    dm = plain.pop("DEFAULT_MONGODB", None)
    if dm == "ORMONGO":
        dm_note = "  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.\n"
    elif dm is not None:
        plain["DEFAULT_MONGODB"] = dm
        dm_note = "  # Non-sensitive config vars. DEFAULT_MONGODB overrides the module base value.\n"
    else:
        dm_note = ("  # Non-sensitive config vars.\n"
                   "  # NOTE: this app has no DEFAULT_MONGODB set live; the module base adds\n"
                   "  # DEFAULT_MONGODB=ORMONGO on first apply.\n")

    d = os.path.join(repo_root, "heroku", "pipeline", pipeline, stage, app)
    os.makedirs(d, exist_ok=True)

    pad = max((len(hcl_key(k)) for k in plain), default=0)
    cfg_lines = "\n".join(f"    {hcl_key(k).ljust(pad)} = {hcl_str(v)}" for k, v in plain.items())
    spad = max((len(hcl_key(k)) for k in secret), default=0)
    sens_lines = "\n".join(f'    {hcl_key(k).ljust(spad)} = var.secrets["{k}"]' for k in secret)

    stack_line = f'  stack          = "{stack}"  # differs from the module default\n' if stack != "heroku-24" else ""
    stage_line = ('  # pipeline_stage defaults to "development"\n' if stage == "development"
                  else f'  pipeline_stage = "{stage}"\n')

    if isinstance(gh, dict) and gh.get("repo"):
        github_block = f"""
  # GitHub integration (live values)
  github_repo   = "{gh['repo']}"
  deploy_branch = "{gh['branch']}"
  auto_deploy   = {str(bool(gh.get('auto_deploy'))).lower()}
  wait_for_ci   = {str(bool(gh.get('wait_for_ci'))).lower()}
"""
    else:
        github_block = """
  # No GitHub integration is configured on this app (github_repo stays null,
  # which skips the Kolkrabbi wiring in the module).
"""

    if owned:
        apad = max(len(s) for s in owned)
        addon_lines = "\n".join(f'    {s.ljust(apad)} = "{p}"' for s, p in sorted(owned.items()))
        addons_block = f"""
  # Add-ons owned by this app
  addons = {{
{addon_lines}
  }}
"""
    else:
        addons_block = "\n  # This app owns no add-ons\n  addons = {}\n"

    frm = "\n".join(f'    {f["type"]} = {{ size = "{f["size"].lower()}", quantity = {f["quantity"]} }}'
                    for f in fm)
    frm_block = f"""
  # Dyno formation (live values)
  formations = {{
{frm}
  }}
""" if fm else """
  # No dyno formation exists on this app
  formations = {}
"""

    injected_note = ""
    if injected_present:
        w = max(len(k) for k in injected_present)
        lines = "\n".join(f"#   - {k.ljust(w)}  -> {injected[k]}" for k in injected_present)
        injected_note = f"""
# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
{lines}
"""

    shared_note = ""
    if shared:
        lines = "\n".join(f"#   - {p}  (billed to {b})" for _, p, b in sorted(shared))
        shared_note = f"""
# -----------------------------------------------------------------------------
# Shared add-ons attached to this app (billed to OTHER apps - not managed here)
# -----------------------------------------------------------------------------
{lines}
"""

    with open(f"{d}/main.tf", "w") as f:
        f.write(f"""# =============================================================================
# {app} - Heroku Application
# =============================================================================
# Part of the "{pipeline}" pipeline, "{stage}" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
#
# Generated by tools/codify_app.py - safe to edit by hand afterwards.
# =============================================================================

module "app" {{
  source = "../../../../modules/rstk-app"

  app_name       = "{app}"
  pipeline_name  = "{pipeline}"
{stage_line}{stack_line}{github_block}{addons_block}{frm_block}
{dm_note}  config_vars = {{
{cfg_lines}
  }}

  # Sensitive config vars - values come from the `secrets` map supplied via
  # terraform.tfvars (gitignored). Explicit lookups so a missing key fails
  # loudly at plan time instead of silently dropping a config var.
  sensitive_config_vars = {{
{sens_lines}
  }}
}}
{injected_note}{shared_note}""")

    with open(f"{d}/variables.tf", "w") as f:
        f.write(f"""# =============================================================================
# {app} - Inputs
# =============================================================================
# All sensitive config var values arrive through this single map, supplied via
# terraform.tfvars (gitignored) or TF_VAR_secrets. The keys this app expects
# are the ones referenced as var.secrets["..."] in main.tf and listed in
# terraform.tfvars.example.
# =============================================================================

variable "secrets" {{
  description = "Sensitive config var values, keyed by config var name"
  type        = map(string)
  sensitive   = true
  default     = {{}}
}}
""")

    with open(f"{d}/outputs.tf", "w") as f:
        f.write(f"""# =============================================================================
# {app} - Outputs (re-exported from the module)
# =============================================================================

output "app_id" {{
  description = "The Heroku app ID"
  value       = module.app.app_id
}}

output "app_name" {{
  description = "The Heroku app name"
  value       = module.app.app_name
}}

output "web_url" {{
  description = "The web URL of the app"
  value       = module.app.web_url
}}

output "git_url" {{
  description = "The Git URL for deploying to this app"
  value       = module.app.git_url
}}

output "heroku_hostname" {{
  description = "The hostname for the app"
  value       = module.app.heroku_hostname
}}

output "pipeline_id" {{
  description = "The pipeline this app belongs to"
  value       = module.app.pipeline_id
}}

output "pipeline_stage" {{
  description = "The pipeline stage"
  value       = module.app.pipeline_stage
}}
""")

    with open(f"{d}/providers.tf", "w") as f:
        f.write(f"""terraform {{
  required_version = ">= 1.6.0"

  required_providers {{
    heroku = {{
      source  = "heroku/heroku"
      version = "~> 5.0"
    }}
    null = {{
      source  = "hashicorp/null"
      version = "~> 3.0"
    }}
  }}

  # Uncomment and configure when ready for remote state
  # backend "s3" {{
  #   bucket = "rootstock-tofu-state"
  #   key    = "heroku/pipeline/{pipeline}/{stage}/{app}/terraform.tfstate"
  #   region = "us-east-1"
  # }}
}}

provider "heroku" {{
  # Set via HEROKU_API_KEY environment variable
}}
""")

    kpad = max((len(hcl_key(k)) for k in secret), default=0)
    header = f"""# =============================================================================
# {app} - Terraform Variables
# =============================================================================
# Copy this file to terraform.tfvars and fill in the sensitive values.
# NEVER commit terraform.tfvars to version control!
# =============================================================================

secrets = {{
"""
    with open(f"{d}/terraform.tfvars.example", "w") as f:
        f.write(header + "".join(f'  {hcl_key(k).ljust(kpad)} = ""\n' for k in secret) + "}\n")
    with open(f"{d}/terraform.tfvars", "w") as f:
        f.write(f"# {app} - sensitive values (gitignored, sourced from live Heroku config)\n"
                "secrets = {\n"
                + "".join(f'  {hcl_key(k).ljust(kpad)} = {hcl_str(cfg[k])}\n' for k in secret)
                + "}\n")

    print(f"{pipeline}/{stage}/{app}: {len(plain)} plain, {len(secret)} secret, "
          f"{len(injected_present)} injected, addons={sorted(owned) or '-'}, stack={stack}, "
          f"gh={'yes' if isinstance(gh, dict) and gh.get('repo') else 'no'}")

if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("pipeline")
    p.add_argument("stage", choices=["development", "staging", "production"])
    p.add_argument("app")
    p.add_argument("--repo-root", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    a = p.parse_args()
    emit(a.pipeline, a.stage, a.app, a.repo_root)
