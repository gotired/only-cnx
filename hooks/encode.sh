#!/usr/bin/env bash
# HMS CNX — Stop encode-enforcement hook.
# Makes durable memory auto-write reliable: if a run scratchpad (.hms-cnx/run/) is
# present AND a valid vault exists to write to, BLOCKS the stop and instructs the model
# to encode learnings to the vault and roll the scratchpad before finishing.
#
# Loop-safe: uses `stop_hook_active` from the hook input so it forces the encode at most
# once per stop chain, then lets the run finish — it can never trap the user.
# No-op when there is no run scratchpad, no valid vault, or no python3. Never reads secrets.
set -euo pipefail

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
run="$proj/.hms-cnx/run"
[ -d "$run" ] || exit 0                       # no run in flight → nothing to enforce
command -v python3 >/dev/null 2>&1 || exit 0  # cannot emit safe JSON → degrade silently

# Capture the hook input (JSON on stdin) BEFORE the heredoc reuses stdin for the script.
input="$(cat 2>/dev/null || true)"

is_valid_vault() { [ -n "${1:-}" ] && { [ -f "$1/MEMORY.md" ] || [ -d "$1/.obsidian" ]; }; }
vault=""
if is_valid_vault "${HMS_CNX_MEMORY:-}"; then
  vault="$HMS_CNX_MEMORY"
elif is_valid_vault "$proj/.hms-cnx/memory"; then
  vault="$proj/.hms-cnx/memory"
fi

# No durable vault to write to → don't block (auto-write impossible); silent no-op.
[ -n "$vault" ] || exit 0

HOOK_INPUT="$input" python3 - "$vault" <<'PY'
import json, os, sys
vault = sys.argv[1]

# Loop safety: if we already forced an encode this stop chain, let the run finish.
stop_active = False
try:
    stop_active = bool(json.loads(os.environ.get("HOOK_INPUT", "") or "{}").get("stop_hook_active"))
except Exception:
    stop_active = False

if stop_active:
    print(json.dumps({
        "continue": True,
        "systemMessage": "HMS CNX: finishing — verify durable learnings were saved to the vault and "
                         ".hms-cnx/run/ was rolled."
    }))
    sys.exit(0)

reason = (
    "HMS CNX team memory has not been encoded yet — a run scratchpad (.hms-cnx/run/) is still present "
    "and a durable vault exists at `%s`. Do NOT finish yet. Before stopping: "
    "(1) write the run's durable learnings to the vault as typed notes — decisions/, conventions/, "
    "contracts/, qa-history/, and per-specialist domain/ as relevant (follow the team-memory skill and its "
    "templates/); (2) update MEMORY.md with one index line per note; (3) ONLY THEN delete .hms-cnx/run/ as "
    "your final action. Use placeholders — never write a secret value into memory." % vault
)
print(json.dumps({"decision": "block", "reason": reason}))
PY
