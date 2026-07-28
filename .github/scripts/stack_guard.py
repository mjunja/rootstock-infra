#!/usr/bin/env python3
"""Stack-only plan guard for stack-rollout.yml.

Passes when the plan contains nothing beyond:
  - heroku_app "stack" changes, and/or
  - the one-time post-import config-var adoption (state has {} after
    `tofu import`), but ONLY if every planned value is byte-identical to
    the app's LIVE config vars (fetched from the Heroku API) - i.e. the
    adoption is pure bookkeeping and changes nothing on Heroku.

Anything else fails the guard. Prints key names only, never values
(the plan JSON embeds secret config vars).

Usage: stack_guard.py <plan.json>   (HEROKU_API_KEY must be set)
"""
import json
import os
import sys
import urllib.request


def live_config(app_name, token):
    req = urllib.request.Request(
        f"https://api.heroku.com/apps/{app_name}/config-vars",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.heroku+json; version=3",
        },
    )
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def main():
    plan = json.load(open(sys.argv[1]))
    token = os.environ["HEROKU_API_KEY"]
    problems = []

    for rc in plan.get("resource_changes", []):
        ch = rc["change"]
        if ch["actions"] in (["no-op"], ["read"]):
            continue
        if rc["type"] != "heroku_app" or ch["actions"] != ["update"]:
            problems.append(f"{rc['address']}: action {'/'.join(ch['actions'])}")
            continue

        before = ch.get("before") or {}
        after = ch.get("after") or {}
        unknown = ch.get("after_unknown") or {}
        live = None

        for k in sorted(set(before) | set(after)):
            if unknown.get(k) is True:  # computed, not a config change
                continue
            if k == "stack" or before.get(k) == after.get(k):
                continue
            if k in ("config_vars", "sensitive_config_vars") and not before.get(k):
                # post-import adoption: allowed only if identical to live
                if live is None:
                    live = live_config(after.get("name") or before.get("name"), token)
                planned = after.get(k) or {}
                bad = sorted(x for x in planned if live.get(x) != planned[x])
                if bad:
                    problems.append(
                        f"{rc['address']}: {k} adoption would CHANGE live value(s) of: {', '.join(bad)}"
                    )
                continue
            problems.append(f"{rc['address']}: attribute '{k}' changes")

    if problems:
        print("::error::stack-only guard: plan goes beyond heroku_app.stack (+ live-identical config adoption):")
        for p in problems:
            print(f"::error::  {p}")
        sys.exit(1)
    print("Guard passed: only stack changes and/or live-identical config-var adoption.")


if __name__ == "__main__":
    main()
