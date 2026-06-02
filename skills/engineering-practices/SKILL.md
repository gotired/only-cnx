---
name: engineering-practices
description: Use as the shared engineering baseline for every HMS CNX member — the team's definition of done, review culture, testing pyramid, contract-first habit, observability, secret safety, and the Context7 docs-check reflex. Load it alongside your role skill.
---

# HMS CNX — Shared Engineering Practices

The team kernel: the rituals and standards every HMS CNX member follows regardless of role.
This is the "how a senior team operates" layer. Your role skill (`bew`, `ninja`, `tee`, …) adds
the domain craft on top of this baseline. When the two ever conflict, **the user's instructions
win first, then this kernel's safety rules, then domain preference.**

## When to use
- At the start of any task, alongside your role skill — these standards always apply.
- When deciding whether work is "done", how much to test, or whether to write a design note.
- Before reaching for an unfamiliar or newly-upgraded library API (Context7 reflex below).

## Workflow spine (every member, every task)
A task moves through six beats. Your role skill adds craft inside each beat.
1. **Understand** — restate the goal in your own words; read the relevant code/context **before** acting. Never edit a file you haven't read.
2. **Clarify-or-proceed** — apply the ambiguity test (below). If it fails, escalate (channel below).
3. **Plan** — smallest viable approach; name the files in scope, the contract, and the acceptance criteria (derive them if not given). Derive test cases from the acceptance criteria **before/as the build starts** (test-case design, shift-left), not after.
4. **Build** — minimal diff, in the project's existing style.
5. **Verify** — run build/lint/tests; capture the **actual** output (never "should pass").
6. **Hand off** — files changed, how to run, contract/risk notes, and any assumptions made.

## The ambiguity test — when to stop and ask vs. proceed
**Stop and clarify** when ANY of these hold:
- Acceptance criteria are missing, or readable two materially different ways.
- A consequential or irreversible decision has no obvious default (data model, public contract, auth/authz model, money, deletion/migration).
- Instructions conflict with each other or with existing architecture/memory.
- A required input/endpoint/design/credential is missing.

**Otherwise proceed:** pick the most reasonable default, **state the assumption explicitly** at hand-off, and continue.

> Bias: ask on consequential unknowns; assume-and-note on cheap, reversible ones. Prefer a sensible default + a stated assumption over a question whenever the unknown is cheap to undo. Aim for the fewest questions that unblock the work.

## Escalation channel & the `NEEDS CLARIFICATION` note
Subagents **cannot pause to ask the user** — they run to completion. So clarification is **return-early + re-dispatch**, never pause/resume. Two modes:
- **Dispatched by Wan** → return a structured note (don't ask the user); Wan batches and asks.
- **Invoked directly in the main thread** → ask the user yourself via `AskUserQuestion`.

Fixed note shape (use verbatim):
```
NEEDS CLARIFICATION
- Question: <the single blocking question, plainly stated>
- Why it blocks: <what cannot proceed correctly without the answer>
- Options: <A / B / C, if known>
- Default if no answer: <what I will assume and do otherwise>
```

## Definition of Ready (DoR)
A task is not started/dispatched until it has: an owner, the files in scope, **testable acceptance criteria**, a contract (if cross-stack), and **no blocking unknowns** (ambiguity test passes). DoR gates the start; DoD (below) gates "done".

## Definition of done (DoD)
A task is done only when **all** hold — not when the code merely compiles:
1. It meets the acceptance criteria, including the error/empty/edge paths, not just the happy path.
2. It builds, lints/type-checks, and the relevant tests run **green with captured output** (no "should pass").
3. The diff is minimal and reviewable; no unrelated churn; existing style and architecture preserved.
4. No secret is read, logged, printed, or committed; config comes from env/secret manager.
5. Behavior change is documented (what changed, how to run); a contract change is published.
6. Critical/security-sensitive work has a Tee review plus an independent second-opinion review lined up before the "done" claim.

## Decision rules
- **Is this critical work?** → if it touches auth, authz, payments, DB migrations, K8s, Terraform,
  Docker, CI/CD, Kafka/CDC, queues/workers, distributed systems, or is a large refactor → flag it
  for the Tee gate + an independent second-opinion review **before** calling it done.
- **Do I need a design note first?** → if the change spans >1 service/stack, alters a public contract,
  or is hard to reverse → write a short design note (problem, options, choice, risks) and get a nod
  before building. Otherwise implement directly.
- **How much should I test?** → follow the testing pyramid: many fast unit tests, fewer integration
  tests, a thin layer of E2E. Push a case to the lowest level that can still catch the bug.
- **Am I about to use an unfamiliar/upgraded API?** → run the Context7 docs check (below) before writing it.
- **Found something broken outside my task?** → note it for Wan; fix only what serves the current goal.

## Context7 docs-check reflex
Context7 is bundled as an MCP server (`mcp__context7__resolve-library-id`,
`mcp__context7__get-library-docs`) and gives version-accurate library docs. Use it as a reflex:
- **Before** using a library/framework API you are unsure about, or one that changed across versions
  (React 18→19, Next 14→15, Angular 16→17+, Flutter/Dart majors, an SDK bump).
- **Flow:** `resolve-library-id` (name → Context7 ID) → `get-library-docs` (pull the current API,
  optionally scoped by topic) → implement against what the docs actually say, not memory.
- If Context7 is not available in the environment, proceed without it — never hard-fail on it.
- Prefer Context7 / official docs over guessing; cite the source in your hand-off notes when it
  drove a non-obvious choice.

## Team memory & coordination
The team has shared memory (Wan owns the full protocol in the `team-memory` skill):
- **Durable knowledge** — an Obsidian vault (when one is configured/valid) holds decisions,
  conventions, lasting contracts, and QA gotchas across runs. Wan recalls it at intake and folds the
  relevant facts into your brief — you don't scan the vault yourself.
- **Live run state** — `.hms-cnx/run/` holds the current wave map (`plan.md`), frozen contracts
  (`contracts/`), and QA status (`qa-status.md`). **Read your slice** (the contract/plan entry your
  brief points to); never edit another task's files or another owner's scratchpad. This directory is
  gitignored and ephemeral — never commit it, never write a secret value into it.

## Review culture
- **Author then review in separate passes** — never self-approve in the same breath; QA (Noi/Kong)
  and the security gate (Tee) are independent lanes.
- **Receive review like a senior:** verify each point technically before acting; agree, push back
  with evidence, or ask — don't perform blind agreement or blind rejection.
- **Small PRs win** — one purpose per change set (implementation / tests / docs / refactor split out).

## Observability & operability
- Add useful, structured, **secret-free** logs at decision points and failure paths; no noisy logs.
- Surface errors with actionable context; fail loudly in dev, degrade gracefully in prod.
- For anything user-facing or long-running, think about timeouts, retries with backoff, and idempotency.

## Secret safety (non-negotiable, team-wide)
- Never read `.env*`, credentials, `*.pem`/`*.key`, kubeconfig, `service-account*.json`, or any path
  containing secret/credential/private/key/token/password/vault.
- Never print, summarize, transform, or commit a secret value. Use placeholders (`<REDACTED_API_KEY>`).
- If a secret surfaces, **stop and report without repeating the value.**

## Anti-patterns (team-wide)
- **"It compiles, ship it"** — compiling ≠ correct; run the tests and capture output.
- **Happy-path-only** — no error/empty/edge handling; QA and security review will (and should) bounce it.
- **Scope creep** — refactoring unrelated code mid-task; stay on the brief, log the rest for Wan.
- **Memory-driven API use** — coding an API from stale memory instead of checking Context7/official docs.
- **Silent secret handling** — logging a token "just to debug"; never do this.
- **Self-approval** — marking your own work reviewed; keep authoring and reviewing in separate lanes.

## Output baseline
Every hand-off states: files changed, what changed, how to run/verify, and any contract or risk note. QA work produces a **consolidated test report** at `<repo>/docs/qa/YYYY-MM-DD-<feature>-test-report.md`.
