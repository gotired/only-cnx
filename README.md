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

Installing the plugin auto-registers two MCP servers (defined in `.mcp.json`):

| Server | Type | Used by | Prerequisite |
|--------|------|---------|--------------|
| `playwright` | stdio (`npx @playwright/mcp@latest`) | Noi, Kong — browser/E2E testing | Node.js + `npx` on PATH (browsers download on first run) |
| `figma` | http (`https://mcp.figma.com/mcp`) | Bew, Oat, Guitar — design-to-code | Figma account; you authenticate on first use |

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

**Parallel-wave pipeline** — Wan builds a dependency map of all files that need to change. Tasks with disjoint file sets run in parallel within the same wave. Contract-first design (OpenAPI stubs, interface types) lets frontend and backend parallelize across waves without blocking on each other.

**Per-task QA fail-loop** — after each specialist finishes, Noi (manual) or Kong (automated) validates the output. Failures are bounced back to the owner with a diff and error summary. The loop repeats up to 3 times before escalating to Wan.

**Tee security gate** — before the consolidated report is delivered, Tee scans every changed file for leaked secrets, insecure defaults, missing auth guards, and CI/CD misconfigurations. Critical findings block the report until fixed.

## Guardrails

- **Secret safety** — no team member reads `.env`, credentials, private keys, kubeconfig, or token files. Real secret values are never printed; placeholders are used instead.
- **File-collision prevention** — Wan assigns one owner per file per wave. Two agents never edit the same file at the same time.
- **Codex routing** — auth, payments, database migrations, and infra changes are flagged for a Tee + Codex review before finalizing.

## Changelog

### 0.2.0

- Bundle MCP servers via `.mcp.json`: `playwright` (QA browser testing) and `figma` (design-to-code). Auto-registered on install.

### 0.1.0

- Initial release: orchestrator (Wan) + 8 specialist members, marketplace packaging.
