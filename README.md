# HMS CNX

A 9-member AI software engineering team plugin for Claude Code — PM-led orchestration plus 8 specialists covering QA, mobile, frontend, backend, AI, and DevSecOps.

## What it is

HMS CNX is a Claude Code plugin that wires up a full engineering team as slash commands. Wan (the PM) runs the full orchestration pipeline: intake, decompose, parallel-wave dispatch, QA fail-loop, and a Tee security gate. Eight specialists — Noi, Kong, Guitar, Bew, Oat, Ninja, Ohm, and Tee — can also be invoked directly for scoped work.

## Install

```
/plugin marketplace add <git-url-or-local-path>
/plugin install hms-cnx
```

> **Note:** commands may appear namespaced (e.g. `/hms-cnx:wan`) depending on the Claude Code version; run `/help` after install to see exact names.

## Bundled MCP servers

Installing the plugin auto-registers three MCP servers (defined in `.mcp.json`):

| Server | Type | Used by | Prerequisite |
|--------|------|---------|--------------|
| `playwright` | stdio (`npx @playwright/mcp@latest`) | Noi, Kong — browser/E2E testing | Node.js + `npx` on PATH (browsers download on first run) |
| `figma` | http (`https://mcp.figma.com/mcp`) | Bew, Oat, Guitar — design-to-code | Figma account; you authenticate on first use |
| `context7` | stdio (`npx -y @upstash/context7-mcp`) | Bew, Oat, Guitar, Ninja, Ohm, Kong — version-accurate library docs | Node.js + `npx` on PATH; no key required (free tier) |

Both are config-light and ship no secrets. Figma uses OAuth on first call — nothing is stored in the repo. If you don't want a server, comment it out of `.mcp.json` after install, or disable it via `/mcp`.

## The team

| Nick | Thai | Role | Model | Core job |
|------|------|------|-------|----------|
| Wan | ว่าน | Project Manager / lead | opus | Analyze requirements, decompose, assign, sequence, prevent file collisions, route critical work to Tee + Codex, consolidate the report. |
| Noi | หน่อย | Manual QA | sonnet | Test dev output (incl. Playwright), write test report, bounce failures back to devs. |
| Kong | ก้อง | Automation QA | sonnet | Write reusable automated test scripts in the repo's test dir. |
| Guitar | กีตาร์ | Flutter / mobile dev | sonnet | Flutter widgets, state mgmt, platform integration, mobile UX. |
| Bew | บิว | React dev | sonnet | React / Next.js, RSC, hooks, frontend perf. |
| Oat | โอ๊ต | Angular dev | sonnet | Angular 17+, RxJS, NgRx, standalone components. |
| Ninja | นินจา | Backend dev | sonnet | TypeScript, PHP, Python, Go — APIs, data, services. |
| Ohm | โอม | AI dev | sonnet | LLM features, agents, RAG, embeddings (Python). |
| Tee | ตี๋ | DevSecOps | opus | Infra, CI/CD, security & secret scanning, cross-team code review. |

## Usage

Use `/hms-cnx <request>` or `/wan <request>` to run the full team orchestration pipeline. Use individual specialist commands for scoped work:

```
/bew     React / Next.js component or page
/ninja   Backend API, service, or data layer
/oat     Angular UI or feature module
/guitar  Flutter screen or widget
/ohm     AI feature, RAG pipeline, or agent
/noi     Manual or Playwright test run
/kong    Automated test scripts
/tee     Security audit or CI/CD review
```

### Worked example

```
/hms-cnx add a profile page with avatar upload backed by a new API endpoint
```

Wan plans two parallel waves:

- **Wave 1 (parallel):** Ninja builds the upload endpoint + OpenAPI contract; Bew scaffolds the profile page against the contract stub.
- **Wave 2 (sequential):** Bew integrates against the live endpoint once Ninja is done.
- **QA:** Noi runs Playwright tests on the profile page and avatar upload flow; failures loop back to the owner (max 3 rounds).
- **Gate:** Tee reviews the endpoint for auth, file-type validation, and secret safety before the report is consolidated.

## How it works

See [`WORKFLOW.md`](./WORKFLOW.md) for the full team workflow and diagram.

**Parallel-wave pipeline** — Wan builds a dependency map of all files that need to change. Tasks with disjoint file sets run in parallel within the same wave. Contract-first design (OpenAPI stubs, interface types) lets frontend and backend parallelize across waves without blocking on each other.

**Per-task QA fail-loop** — after each specialist finishes, Noi (manual) or Kong (automated) validates the output. Failures are bounced back to the owner with a diff and error summary. The loop repeats up to 3 times before escalating to Wan.

**Tee security gate** — before the consolidated report is delivered, Tee scans every changed file for leaked secrets, insecure defaults, missing auth guards, and CI/CD misconfigurations. Critical findings block the report until fixed.

**Shared engineering baseline** — every member loads the `engineering-practices` skill alongside their role skill: a common definition of done, review culture, the testing pyramid, secret safety, and a "check current docs via Context7 before using an unfamiliar or upgraded library API" reflex. Each role skill (`bew`, `ninja`, `tee`, …) now also carries explicit decision rules, a named anti-pattern catalog, worked before/after examples, and a verification checklist.

**Team memory** — the team remembers across runs. Wan **recalls** durable knowledge at intake and **encodes** what the team learned at report time, via the `team-memory` skill. Two tiers with graceful degradation:

- **Durable knowledge** lives in an **Obsidian vault** when one is available. The vault is resolved from `$HMS_CNX_MEMORY` (an external/shared vault) or the in-repo `.hms-cnx/memory/` (committed, so knowledge travels with the repo); a vault is valid if it contains `.obsidian/` or a `MEMORY.md`. It holds Decisions, Conventions, Contracts, QA-History, and per-specialist Domain notes.
- **Coordination scratchpad** — `.hms-cnx/run/` (gitignored, ephemeral) holds the live wave map, frozen contracts, and QA status during a run. This is the always-on fallback when no durable vault exists.

No secret value is ever written to memory (placeholders only), and the plugin is self-contained — it assumes no particular person's vault or machine.

## Guardrails

- **Secret safety** — no team member reads `.env`, credentials, private keys, kubeconfig, or token files. Real secret values are never printed; placeholders are used instead.
- **File-collision prevention** — Wan assigns one owner per file per wave. Two agents never edit the same file at the same time.
- **Codex routing** — auth, payments, database migrations, and infra changes are flagged for a Tee + Codex review before finalizing.

## Changelog

### 0.6.0

- Add **team memory** via the new `team-memory` skill: Wan recalls durable knowledge at intake and encodes decisions/conventions/contracts/QA-gotchas at report time. Durable memory uses an Obsidian-compatible markdown vault (`$HMS_CNX_MEMORY` or in-repo `.hms-cnx/memory/`) when valid; otherwise the team falls back to the `.hms-cnx/run/` coordination scratchpad (gitignored, ephemeral) that also carries live wave-map, frozen contracts, and QA status during every run. The HMS CNX Report now includes a Memory section. No secret values are ever written to memory.
- Define a structured memory layout: typed notes (`decisions/`, `conventions/`, `contracts/`, `qa-history/`, `domain/`) with a frontmatter schema (`type`/`project`/`status`/`tags`/dates), a tagged `MEMORY.md` recall map for O(index) recall, supersede-don't-delete pruning, multi-project scoping for shared vaults, and copyable note templates shipped in `skills/team-memory/templates/`.
- Add a daily activity log (episodic memory): each Wan-led run appends a per-agent entry to `daily/YYYY-MM-DD.md` in the vault (request, who did what, outcome, changes, notes encoded) as part of the mandatory encode, so the team tracks what it did each day. The `SessionStart` hook injects today's date so the filename is correct; daily logs are read on demand (standups, "what did we do this week").
- Add enforcement hooks (`hooks/hooks.json`): a `SessionStart` hook injects the vault's `MEMORY.md` so recall can't be skipped, and a `Stop` hook that **blocks a team run from finishing until durable memory is encoded** (and the `.hms-cnx/run/` scratchpad is rolled) whenever a valid vault exists — so memory auto-writes rather than being optional. The Stop hook is loop-safe (forces the encode at most once per stop chain via `stop_hook_active`) and only enforces when there's a vault to write to. Both hooks no-op in any repo without a team vault/run and never read secret files.

### 0.5.0

- Add the shared `engineering-practices` skill (team definition of done, review culture, testing pyramid, observability, secret safety, Context7 docs-check reflex); every agent loads it alongside its role skill.
- Deepen all 10 role skills with explicit decision rules, a named anti-pattern catalog, worked before/after examples, a verification checklist, and authoritative references.
- Bundle the `context7` MCP server for version-accurate library docs; wire it into the developer agents' (Bew, Oat, Guitar, Ninja, Ohm) and Kong's workflow and tool usage.

### 0.4.0

- Add `WORKFLOW.md` documenting the end-to-end team workflow (with a flow diagram), and expand each specialist's `<Work_Protocol>` into a fuller role-specific workflow that includes brief intake, QA hand-off, the fix-loop on bounce-back, and escalation.

### 0.3.0

- Add a `<Recommended_Skills>` section to every agent: optional, graceful "use if available" references (planning/parallel-dispatch for Wan, security/code review for Tee, verify/run for QA, TDD for devs, frontend-design + Figma for Bew/Oat/Guitar, claude-api/deep-research for Ohm).

### 0.2.0

- Bundle MCP servers via `.mcp.json`: `playwright` (QA browser testing) and `figma` (design-to-code). Auto-registered on install.

### 0.1.0

- Initial release: orchestrator (Wan) + 8 specialist members, marketplace packaging.
