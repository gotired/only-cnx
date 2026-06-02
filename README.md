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

Installing the plugin auto-registers four MCP servers (defined in `.mcp.json`):

| Server | Type | Used by | Prerequisite |
|--------|------|---------|--------------|
| `playwright` | stdio (`npx @playwright/mcp@latest`) | Noi, Kong — browser/E2E testing | Node.js + `npx` on PATH (browsers download on first run) |
| `figma` | http (`https://mcp.figma.com/mcp`) | Bew, Oat, Guitar — design-to-code | Figma account; you authenticate on first use |
| `context7` | stdio (`npx -y @upstash/context7-mcp`) | Bew, Oat, Guitar, Ninja, Ohm, Kong — version-accurate library docs | Node.js + `npx` on PATH; no key required (free tier) |
| `atlassian` | http (`https://mcp.atlassian.com/v1/mcp`) | Wan, Noi, Kong — Jira issue tracking (read criteria, log defects, transition status) | Atlassian Cloud account; OAuth in browser on first use |

These are config-light and ship no secrets. Figma and Atlassian use OAuth on first call — nothing is stored in the repo. The Atlassian server targets Atlassian **Cloud** (Jira/Confluence); the legacy `/v1/sse` endpoint is being retired, so this config uses the current `/v1/mcp` streamable-HTTP endpoint. If you don't want a server, comment it out of `.mcp.json` after install, or disable it via `/mcp`.

## The team

| Nick | Thai | Role | Model | Core job |
|------|------|------|-------|----------|
| Wan | ว่าน | Project Manager / lead | opus | Analyze requirements, decompose, assign, sequence, prevent file collisions, route critical work to Tee plus an independent second-opinion review, consolidate the report. |
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
- **second-opinion routing** — auth, payments, database migrations, and infra changes are flagged for a Tee review plus an independent second-opinion review before finalizing.

## Changelog

### 0.7.0

- Bundle the **Atlassian (Jira) MCP server** (`https://mcp.atlassian.com/v1/mcp`, streamable-HTTP) so Wan, Noi, and Kong can ground work in the tracker — pull acceptance criteria, log/transition issues, and link defects. OAuth on first use; no tokens stored.
- Add a **Wan-gated user-clarification loop**. Wan now runs an **ambiguity test at intake** and asks the user a small batch (1–4) of targeted, mostly multiple-choice questions when a request is underspecified, instead of silently guessing. Because subagents cannot pause mid-run, clarification is **return-early + re-dispatch**: a specialist that hits a blocking unknown returns a structured `NEEDS CLARIFICATION` note to Wan (or, when invoked directly, asks the user itself), Wan asks the user, then re-dispatches with the answer.
- Add a shared **workflow spine** (Understand → Clarify-or-proceed → Plan → Build → Verify → Hand off), an explicit **ambiguity test**, the fixed `NEEDS CLARIFICATION` note shape, and a **Definition of Ready** to the `engineering-practices` skill — inherited by every member.
- Normalize every agent's workflow with a **dual-mode clarification branch** (escalate to Wan when dispatched, ask the user when invoked directly). QA (Noi/Kong) now requires testable acceptance criteria before testing; Tee escalates findings with no safe in-scope fix.
- Close the dev↔QA gap: confirmed **acceptance criteria are written into `.hms-cnx/run/plan.md`** so QA tests the same bar the dev built to. The HMS CNX Report gains an **Assumptions made** section, and resolved clarifications are encoded to team memory as decisions.
- Add a **test-first flow**: QA (Noi/Kong) author test cases from acceptance criteria at **Wave 0 — freeze contract + design test cases**, before development (a **soft gate** — devs start once cases are drafted). After QA runs, the team always writes one **consolidated test report** at `docs/qa/YYYY-MM-DD-<feature>-test-report.md` (Wan assembles Noi's + Kong's results).
- Add copyable **dispatch templates** (`skills/hms-cnx/templates/`: `brief.md`, `contract.md`, `test-report.md`), a **backend import-safe-entrypoint** convention (Ninja exports an app factory; only `listen()`s under a main-module guard so QA can test in-process), and a **QA ephemeral-port** convention (bind `PORT=0`, never hard-code) to avoid collisions in parallel test runs.

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
