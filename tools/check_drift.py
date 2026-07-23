#!/usr/bin/env python3
"""Read-only drift check: compare every codified app folder against live Heroku.

For each heroku/pipeline/<pipeline>/<stage>/<app>/ folder, parse main.tf (the
codify_app.py format) and compare against the live app via the same read-only
GETs codify_app.py uses. NOTHING is ever changed on Heroku - no tofu, no
state, no writes.

Compares: stack, pipeline coupling (name + stage), non-sensitive config vars
(keys AND values), sensitive config vars (key presence; values too when a
local terraform.tfvars exists), owned add-ons, dyno formations, and GitHub
wiring (repo / branch / auto_deploy / wait_for_ci).

Usage:
    python3 tools/check_drift.py [app-dir ...]     # default: all app folders
    e.g. python3 tools/check_drift.py worker/staging/worker-rstk-qa
"""
import json, os, re, subprocess, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from codify_app import api_get, classify_injected, is_sensitive, sh

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODULE_DEFAULT_STACK = "heroku-24"
MODULE_BASE_CONFIG = {"DEFAULT_MONGODB": "ORMONGO"}  # from modules/rstk-app/locals.tf


def unescape(v):
    return (v.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
             .replace('$${', '${').replace('%%{', '%{'))


KV_RE = re.compile(r'^\s*"?([\w.-]+)"?\s*=\s*"(.*)"\s*$')
SECRET_RE = re.compile(r'^\s*"?([\w.-]+)"?\s*=\s*var\.secrets\["(.+)"\]\s*$')
FORMATION_RE = re.compile(
    r'^\s*"?([\w-]+)"?\s*=\s*\{\s*size\s*=\s*"([^"]+)"\s*,?\s*quantity\s*=\s*(\d+)\s*,?\s*\}')
SCALAR_RE = re.compile(r'^\s*(\w+)\s*=\s*("([^"]*)"|true|false|null)\s*(#.*)?$')


def parse_blocks(text):
    """Yield (name, list-of-lines) for each `name = {` ... `}` map block."""
    blocks, cur, depth, name = {}, [], 0, None
    for line in text.splitlines():
        s = line.split('#')[0].rstrip() if not name else line.rstrip()
        m = re.match(r'^\s*(\w+)\s*=\s*\{\s*$', s)
        if name is None and m:
            name, cur, depth = m.group(1), [], 1
            continue
        if name is not None:
            depth += s.count('{') - s.count('}')
            if depth <= 0:
                blocks[name] = cur
                name = None
            else:
                cur.append(line)
    return blocks


def parse_main_tf(path):
    text = open(path).read()
    tf = {"config_vars": {}, "secret_keys": set(), "addons": {},
          "formations": {}, "github_repo": None, "deploy_branch": None,
          "auto_deploy": False, "wait_for_ci": False,
          "stack": MODULE_DEFAULT_STACK, "pipeline_stage": "development"}

    for line in text.splitlines():
        m = SCALAR_RE.match(line)
        if not m:
            continue
        key, raw, strval = m.group(1), m.group(2), m.group(3)
        if key in ("app_name", "pipeline_name", "pipeline_stage", "stack",
                   "github_repo", "deploy_branch"):
            tf[key] = strval
        elif key in ("auto_deploy", "wait_for_ci"):
            tf[key] = raw == "true"

    blocks = parse_blocks(text)
    for line in blocks.get("config_vars", []):
        m = KV_RE.match(line.split(' # ')[0])
        if m:
            tf["config_vars"][m.group(1)] = unescape(m.group(2))
    for line in blocks.get("sensitive_config_vars", []):
        m = SECRET_RE.match(line)
        if m:
            tf["secret_keys"].add(m.group(1))
    for line in blocks.get("addons", []):
        m = KV_RE.match(line)
        if m:
            tf["addons"][m.group(1)] = m.group(2)
    for line in blocks.get("formations", []):
        m = FORMATION_RE.match(line)
        if m:
            tf["formations"][m.group(1)] = (m.group(2).lower(), int(m.group(3)))
    return tf


def parse_tfvars(path):
    if not os.path.exists(path):
        return None
    vals = {}
    for line in open(path).read().splitlines():
        m = KV_RE.match(line.split(' # ')[0])
        if m and m.group(1) != "secrets":
            vals[m.group(1)] = unescape(m.group(2))
    return vals


def check_app(rel_dir, token):
    pipeline, stage, app = rel_dir.split('/')
    d = os.path.join(REPO, "heroku", "pipeline", rel_dir)
    tf = parse_main_tf(os.path.join(d, "main.tf"))
    tfvars = parse_tfvars(os.path.join(d, "terraform.tfvars"))
    drifts = []

    try:
        info = json.loads(sh(["heroku", "apps:info", "-a", app, "--json"]))
        cfg = json.loads(sh(["heroku", "config", "-a", app, "--json"]))
    except subprocess.CalledProcessError:
        return [f"LIVE APP NOT FOUND (or no access): {app}"]
    fm = api_get(f"https://api.heroku.com/apps/{app}/formation", token)
    gh = api_get(f"https://kolkrabbi.heroku.com/apps/{info['app']['id']}/github", token)
    coupling = api_get(f"https://api.heroku.com/apps/{app}/pipeline-couplings", token)

    # --- stack (running stack; a pending build-stack change shows via apps:info) ---
    live_stack = info["app"]["stack"]["name"]
    build_stack = (info["app"].get("build_stack") or {}).get("name", live_stack)
    if tf["stack"] != live_stack:
        drifts.append(f"stack: tf={tf['stack']}  live={live_stack}" +
                      (f" (build_stack={build_stack})" if build_stack != live_stack else ""))
    elif build_stack != live_stack:
        drifts.append(f"stack: live app has PENDING build_stack={build_stack} (running {live_stack})")

    # --- pipeline coupling ---
    if isinstance(coupling, dict) and coupling.get("pipeline"):
        live_pipe = coupling["pipeline"]["name"]
        live_stage = coupling["stage"]
        if tf.get("pipeline_name") != live_pipe or tf["pipeline_stage"] != live_stage:
            drifts.append(f"pipeline: tf={tf.get('pipeline_name')}/{tf['pipeline_stage']}  "
                          f"live={live_pipe}/{live_stage}")
    else:
        drifts.append("pipeline: app has NO live pipeline coupling")

    # --- config vars ---
    injected = classify_injected(info, cfg)
    expected = dict(MODULE_BASE_CONFIG)
    expected.update(tf["config_vars"])
    live_plain = {k: v for k, v in cfg.items()
                  if not is_sensitive(k) and k not in injected}
    for k, v in sorted(expected.items()):
        if k not in cfg:
            drifts.append(f"config var {k}: in tf, MISSING live")
        elif cfg[k] != v:
            drifts.append(f"config var {k}: tf={v!r}  live={cfg[k]!r}")
    for k in sorted(set(live_plain) - set(expected)):
        drifts.append(f"config var {k}: live-only (={live_plain[k]!r}), not in tf")

    # --- sensitive config vars ---
    live_secret = {k for k in cfg if is_sensitive(k) and k not in injected}
    for k in sorted(tf["secret_keys"] - live_secret):
        drifts.append(f"secret {k}: in tf, MISSING live")
    for k in sorted(live_secret - tf["secret_keys"]):
        drifts.append(f"secret {k}: live-only, not managed in tf")
    if tfvars is not None:
        for k in sorted(tf["secret_keys"] & live_secret & set(tfvars)):
            if tfvars[k] != cfg[k]:
                drifts.append(f"secret {k}: VALUE differs (local tfvars vs live)")

    # --- owned add-ons ---
    live_owned = {ad["addon_service"]["name"]: ad["plan"]["name"]
                  for ad in info.get("addons", [])
                  if ad.get("billing_entity", {}).get("name") == app}
    for svc in sorted(set(tf["addons"]) | set(live_owned)):
        t, l = tf["addons"].get(svc), live_owned.get(svc)
        if t != l:
            drifts.append(f"addon {svc}: tf={t}  live={l}")

    # --- formations ---
    live_fm = {f["type"]: (f["size"].lower(), f["quantity"]) for f in fm} if isinstance(fm, list) else {}
    for t in sorted(set(tf["formations"]) | set(live_fm)):
        a, b = tf["formations"].get(t), live_fm.get(t)
        if a != b:
            drifts.append(f"formation {t}: tf={a}  live={b}")

    # --- github wiring ---
    live_gh = gh if isinstance(gh, dict) and gh.get("repo") else {}
    pairs = [("github_repo", live_gh.get("repo")),
             ("deploy_branch", live_gh.get("branch")),
             ("auto_deploy", bool(live_gh.get("auto_deploy"))),
             ("wait_for_ci", bool(live_gh.get("wait_for_ci")))]
    if tf["github_repo"] or live_gh:
        for key, live_val in pairs:
            if tf[key] != live_val and not (key != "github_repo" and not tf["github_repo"] and not live_gh):
                drifts.append(f"{key}: tf={tf[key]!r}  live={live_val!r}")
    return drifts


def main():
    token = os.environ.get("HEROKU_API_KEY") or sh(["heroku", "auth:token"]).strip()
    base = os.path.join(REPO, "heroku", "pipeline")
    if len(sys.argv) > 1:
        dirs = sys.argv[1:]
    else:
        dirs = sorted(os.path.relpath(os.path.join(r), base)
                      for r, ds, fs in os.walk(base) if "main.tf" in fs)
    clean, drifted, errors = [], {}, {}
    for rel in dirs:
        try:
            drifts = check_app(rel, token)
        except Exception as e:  # keep going; report at the end
            errors[rel] = f"{type(e).__name__}: {e}"
            print(f"ERROR {rel}: {errors[rel]}", flush=True)
            continue
        if drifts:
            drifted[rel] = drifts
            print(f"DRIFT {rel}", flush=True)
            for d in drifts:
                print(f"    - {d}")
        else:
            clean.append(rel)
            print(f"OK    {rel}", flush=True)

    print(f"\n===== SUMMARY: {len(clean)} clean, {len(drifted)} drifted, {len(errors)} errors =====")
    for rel in drifted:
        print(f"  drift: {rel} ({len(drifted[rel])} finding(s))")
    for rel, e in errors.items():
        print(f"  error: {rel} ({e})")
    sys.exit(1 if drifted or errors else 0)


if __name__ == "__main__":
    main()
