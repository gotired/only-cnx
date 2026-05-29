---
name: team-memory
description: Use to give the HMS CNX team memory — recall durable knowledge at intake and encode decisions/conventions/gotchas at report time. Prefers an Obsidian vault when one is available; falls back to a within-run coordination scratchpad. Wan owns this; specialists read their slice of run state.
---

# HMS CNX — Team Memory

Stateless subagents forget everything between dispatches and between sessions. This skill gives the
team a shared memory so the PM (Wan) can **recall** what the team already knows before planning and
**encode** what it learned before finishing. Two tiers, with graceful degradation:

1. **Durable knowledge — an Obsidian vault** (survives across runs and sessions). Used when a valid
   vault is available.
2. **Coordination scratchpad — `.hms-cnx/run/`** (survives within a single run). Always available;
   the fallback when no durable vault exists, and the live hand-off surface during every run.

This memory is **self-contained and portable** — it never assumes any particular person's vault or
machine. A team clones the repo and gets the team's memory with it.

## Resolving the durable vault
Resolve the vault path in this order; the first that exists wins:
1. `$HMS_CNX_MEMORY` — explicit path override (an external/shared synced vault).
2. `.hms-cnx/memory/` — the in-repo team vault (committed, so knowledge travels with the repo).

**A vault is *valid* only if** the resolved directory exists **and** contains an `.obsidian/` folder
(the Obsidian marker) **or** a top-level `MEMORY.md`. If neither resolves to a valid vault →
durable memory is **OFF**; use the coordination scratchpad alone and note in the report that durable
memory was unavailable.

Bootstrap (only when the team wants durable memory and none exists): create `.hms-cnx/memory/` with a
`MEMORY.md` index and the folders below; opening that folder once in Obsidian adds `.obsidian/`.

## Vault structure
Plain markdown — Obsidian-compatible but not Obsidian-dependent. Folder names are lowercase.
```
<vault>/
  MEMORY.md          # the recall map — read FIRST at intake (see format below)
  decisions/         # ADR-lite: context · decision · why · consequences · scope
  conventions/       # how things are done in THIS repo, per stack (build, test, style, deploy)
  contracts/         # durable, frozen API/interface contracts other tasks keep depending on
  qa-history/        # recurring failures, flaky areas, known gotchas worth not re-learning
  domain/            # per-specialist learnings — bew.md ninja.md oat.md guitar.md ohm.md tee.md
  templates/         # typed note templates (copied here at bootstrap from this skill's templates/)
```
**Bootstrap** (when the team wants durable memory and none exists): create the folders above, copy
this skill's `templates/` into the vault, and seed `MEMORY.md` from `templates/MEMORY.md`. Opening the
folder once in Obsidian adds `.obsidian/`, but the `MEMORY.md` marker alone makes the vault valid.

## Note schema
Every note carries this frontmatter — it is what makes recall and pruning mechanical, not guesswork:
```yaml
---
name: <kebab-id>                 # stable identifier (also the filename stem)
type: decision|convention|contract|qa|domain
title: <human title>
project: <repo-name | "*">       # "*" = cross-project (lives at root of an external/shared vault)
status: active|superseded|deprecated
created: YYYY-MM-DD              # absolute dates only
updated: YYYY-MM-DD
tags: [<stack/area>, ...]        # e.g. backend, auth, react — what recall matches against
related: ["[[other-note]]"]      # cross-links
---
```
Keep **one fact per note**. Per-type body shapes live in `templates/` (see this skill's `templates/`
directory): decision = context·decision·why·consequences·scope; convention = rule·applies-to·example·why;
contract = request·response·codes·auth·owner·version; qa = area·repro·root-cause·fix·guard; domain =
a dated running list of role-specific learnings about this codebase.

## MEMORY.md — the recall map
One line per note, grouped by type, each carrying a hook + tags + date so Wan can judge relevance from
the index **without opening every note**:
```
## Decisions
- [Auth via short-lived JWT + refresh](decisions/auth-jwt-refresh.md) — dropped server sessions · backend,auth · 2026-05-20
## Contracts
- [POST /orders](contracts/post-orders.md) — order create; consumers: Bew · v2 · 2026-05-22
```
Every create/update/supersede edits exactly one MEMORY.md line. Keep it sorted newest-first per section.

## Recall strategy (scoped & cheap)
Recall is O(index), never O(all notes):
1. Read `MEMORY.md` (small — one line per note).
2. Classify the request (stacks, area, files touched) and match it against the index lines' tags + titles.
3. Open only the matched notes — cap at the most relevant ~10; for an external vault, filter to
   `project == <this repo>` plus cross-project (`project: "*"`) notes.
4. Fold the pertinent facts into each specialist's brief. Specialists never scan the vault themselves.

## Pruning & consolidation
- **Supersede, don't silently delete** — when a decision/convention changes, set the old note's
  `status: superseded`, link the replacement in `related`, and keep it for history. Delete only
  proven-wrong noise.
- **Consolidate when a folder grows large** — merge overlapping notes into one canonical note; mark
  merged-away notes `deprecated`. This keeps recall fast and `MEMORY.md` readable (mitigates bloat).
- **Re-verify before acting on stale memory** — if a note names a file/flag/command, confirm it still
  exists before relying on it; update or supersede the note if reality has moved.

## Multi-project (external/shared vault)
A repo-local `.hms-cnx/memory/` is implicitly single-project (it *is* the project). An external
`$HMS_CNX_MEMORY` vault shared across repos uses the `project:` frontmatter field to scope notes:
per-repo notes set `project: <repo-name>`; conventions that hold everywhere set `project: "*"`. Recall
filters by the current repo + `"*"`; `MEMORY.md` may group sections by project when many repos share one vault.

## The coordination scratchpad (`.hms-cnx/run/`)
Always-on, **gitignored**, ephemeral live state for the current run:
```
.hms-cnx/run/
  plan.md            # the wave map: task → owner → files → deps → criticality
  contracts/         # interfaces frozen this run (consumers read these to build in parallel)
  qa-status.md       # per-task verdict + fail-loop round count
```
Specialists **read their slice** (their brief points to the relevant contract/plan entry); they do
**not** edit another task's files or another owner's scratchpad. Wan owns `plan.md`/`qa-status.md`.

## Lifecycle (Wan runs this)
1. **Recall (at intake)** — resolve the vault; if valid, read `MEMORY.md`, then the `Decisions/` and
   `Conventions/` notes relevant to the request, plus any matching `Contracts/`, `QA-History/`, and
   per-`Domain/` notes for the specialists about to be dispatched. Fold the relevant facts into each
   specialist's brief — specialists don't scan the vault themselves (keeps them focused and cheap).
2. **Coordinate (during the run)** — write the wave map to `.hms-cnx/run/plan.md`; freeze contracts
   into `.hms-cnx/run/contracts/`; track QA verdicts in `qa-status.md`. This is the live hand-off memory.
3. **Encode (at report time)** — when durable memory is ON, persist what the team learned and update
   `MEMORY.md`:
   - **Decisions/** — any architecture/design decision made and why.
   - **Conventions/** — a repo convention discovered or established (test cmd, lint rule, structure).
   - **Contracts/** — promote a contract that downstream work will keep depending on.
   - **QA-History/** — a non-obvious failure/gotcha worth not re-discovering.
   - **Domain/** — a durable per-specialist learning.
   Update or correct existing notes instead of duplicating; delete notes proven wrong. Encoding is
   **mandatory** when a vault exists — write the notes and `MEMORY.md` first, then **roll/clear the run
   scratchpad as your final action** (the `Stop` hook blocks finishing until `.hms-cnx/run/` is gone when a
   vault exists). When durable memory is OFF (no valid vault), skip encoding and say so in the report.

## Enforcement (hooks)
The prompt-level protocol above is the source of truth; two bundled hooks back it up so it isn't
silently skipped (both no-op unless they apply, and never read secret files):
- **`SessionStart` → `hooks/recall.sh`** — if a valid vault exists (`$HMS_CNX_MEMORY` or
  `.hms-cnx/memory/`), injects `MEMORY.md` into context at session start, so recall is guaranteed even
  before Wan acts. Silent no-op in any repo without a vault.
- **`Stop` → `hooks/encode.sh`** — if a run scratchpad (`.hms-cnx/run/`) is present **and a valid vault
  exists to write to**, it **blocks the stop** and instructs the model to encode durable learnings, update
  `MEMORY.md`, and roll the scratchpad before finishing — so durable memory is written automatically, not
  optionally. Loop-safe: it forces the encode at most once per stop chain (via `stop_hook_active`), then
  lets the run finish, so it can never trap the user. It does **not** block when there is no valid vault
  (nothing to persist to). Because only the model can compose meaningful notes, the hook guarantees the
  encode *happens*; the model still writes the content.

## Decision rules
- **Recall or skip?** → always attempt recall at intake; if no valid vault, proceed on the scratchpad alone.
- **Encode this?** → durable only if it will matter to a *future* run: a decision, a convention, a
  lasting contract, or a costly-to-rediscover gotcha. One-off run state stays in the scratchpad.
- **Update or create?** → if a note already covers the topic, update it; never duplicate.
- **In-repo vault or external?** → committed `.hms-cnx/memory/` shares knowledge with the whole team;
  `$HMS_CNX_MEMORY` points at a synced/private vault when the team prefers that. Resolution handles both.

## Anti-patterns
- **No recall** — replanning from scratch when the vault already records the decision/gotcha → read `MEMORY.md` first.
- **Encoding run noise** — saving transient task state as durable knowledge → keep it in `.hms-cnx/run/`.
- **Duplicate notes** — a new note for a topic already covered → update the existing one.
- **Specialists scanning the whole vault** — N agents reading everything → Wan injects the relevant slice into briefs.
- **Stale memory trusted blindly** — acting on a note that names a file/flag without re-verifying it still exists.
- **Committing the scratchpad** — `.hms-cnx/run/` must stay gitignored; only the durable vault is committed.

## Secret safety (non-negotiable)
Memory is exactly where secrets get accidentally persisted. **Never** write a secret value into the
vault or the scratchpad — use placeholders (`<REDACTED_API_KEY>`, `<CONNECTION_STRING>`). Never read
`.env*`/credentials/keys/kubeconfig/token files to source a memory note. If a secret would land in
memory, stop and redact it first. (See `engineering-practices`.)

## Output
At report time, Wan states: vault resolved (path or "none — scratchpad only"), what was recalled that
shaped the plan, and what was encoded (the notes created/updated, by folder).
