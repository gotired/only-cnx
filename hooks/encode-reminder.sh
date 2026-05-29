#!/usr/bin/env bash
# HMS CNX — Stop encode-reminder hook (non-blocking).
# When a run scratchpad (.hms-cnx/run/) is present, nudges the team to encode durable
# learnings and roll the scratchpad before finishing. Never blocks; never loops (it
# stops firing once the scratchpad is rolled). No-op everywhere else.
set -euo pipefail

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
run="$proj/.hms-cnx/run"

# Only nudge if a team run actually left a scratchpad.
[ -d "$run" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

is_valid_vault() { [ -n "${1:-}" ] && { [ -f "$1/MEMORY.md" ] || [ -d "$1/.obsidian" ]; }; }

vault_state="OFF (scratchpad only)"
if is_valid_vault "${HMS_CNX_MEMORY:-}"; then
  vault_state="ON ($HMS_CNX_MEMORY)"
elif is_valid_vault "$proj/.hms-cnx/memory"; then
  vault_state="ON ($proj/.hms-cnx/memory)"
fi

python3 - "$vault_state" <<'PY'
import json, sys
vault_state = sys.argv[1]
msg = (
    "HMS CNX: a run scratchpad (.hms-cnx/run/) is present; durable memory is %s. "
    "If the run is complete, ENCODE durable learnings (decisions / conventions / contracts / qa-history), "
    "update MEMORY.md, and roll the scratchpad. Use placeholders — never write secret values."
) % vault_state
print(json.dumps({"continue": True, "systemMessage": msg}))
PY
