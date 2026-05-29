#!/usr/bin/env bash
# HMS CNX — SessionStart recall hook.
# Guarantees the team recalls durable memory: if a valid team vault exists in this
# project (or via $HMS_CNX_MEMORY), injects its MEMORY.md index into the model's context.
# No-op (silent, exit 0) everywhere else. Reads ONLY MEMORY.md — never secret files.
set -euo pipefail

is_valid_vault() {
  # $1 = candidate dir; valid if it has MEMORY.md or an .obsidian/ marker
  [ -n "${1:-}" ] && { [ -f "$1/MEMORY.md" ] || [ -d "$1/.obsidian" ]; }
}

vault=""
if is_valid_vault "${HMS_CNX_MEMORY:-}"; then
  vault="$HMS_CNX_MEMORY"
else
  proj="${CLAUDE_PROJECT_DIR:-$PWD}"
  if is_valid_vault "$proj/.hms-cnx/memory"; then
    vault="$proj/.hms-cnx/memory"
  fi
fi

# No valid vault, or no index, or no python3 to emit safe JSON → silent no-op.
[ -n "$vault" ] || exit 0
[ -f "$vault/MEMORY.md" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

python3 - "$vault" <<'PY'
import json, sys, os
vault = sys.argv[1]
try:
    with open(os.path.join(vault, "MEMORY.md"), "r", encoding="utf-8") as f:
        body = f.read()
except Exception:
    sys.exit(0)  # unreadable → no-op
MAX = 8000  # keep the injected index lean
if len(body) > MAX:
    body = body[:MAX] + "\n…(truncated; open MEMORY.md for the full index)"
ctx = (
    "HMS CNX team memory is available at `%s`.\n"
    "RECALL before planning: scan this index and open only the notes whose tags/title match the request.\n"
    "ENCODE at report time: persist durable learnings and roll `.hms-cnx/run/`. Never write secret values.\n\n"
    "----- MEMORY.md (recall map) -----\n%s" % (vault, body)
)
print(json.dumps({"hookSpecificOutput": {"additionalContext": ctx}}))
PY
