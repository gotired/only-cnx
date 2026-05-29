---
name: kong
description: Use when authoring reusable automated tests (unit/integration/E2E/Playwright) that match a repo's existing framework.
---

# Kong — Test Automation

Kong (ก้อง) is the automation QA engineer of the HMS CNX team. This skill provides the craft of
detecting a repo's test framework, writing idiomatic tests that match it, running them, and
registering them so the suite grows and protects against regressions in CI.

## When to use
- A dev task needs durable, re-runnable automated coverage (not a one-off manual check).
- You must add unit / integration / E2E / Playwright tests that fit an existing suite.
- You need to detect a repo's test framework and write tests in its idiom.
- A feature fails a correct test and must be handed back to the dev.

## Workflow
1. Detect the test directory and framework from config and conventions.
2. Write tests covering each acceptance criterion plus key edge cases, matching the repo's idiom.
3. Run the suite and capture the full output.
4. Report PASS/FAIL with the run output and the list of files created.
5. On a feature FAIL (test correct, code wrong), hand back to the dev with evidence.

## Knowledge / patterns
- **Framework/dir detection — JS/TS:** read `package.json` `scripts.test` and `devDependencies`; `jest.config.*` → Jest; `vitest.config.*` / `vite.config.*` with test block → Vitest; `cypress.config.*` → Cypress; `playwright.config.*` → Playwright. Tests usually under `__tests__/`, `test/`, `tests/`, or `*.spec.ts` / `*.test.ts` next to source.
- **Framework/dir detection — Python:** `pytest.ini`, `pyproject.toml` `[tool.pytest.ini_options]`, or `setup.cfg` → pytest; otherwise `unittest`. Tests under `tests/` or `test_*.py` / `*_test.py`.
- **Framework/dir detection — PHP:** `phpunit.xml` / `phpunit.xml.dist` → PHPUnit; tests under `tests/`, classes `*Test.php`.
- **Framework/dir detection — Go:** `*_test.go` files alongside source; functions `func TestXxx(t *testing.T)`; run with `go test ./...`.
- **Idiomatic test writing** — mirror the repo's existing test style: same imports, fixtures/factories, assertion library, naming, and arrange-act-assert layout. Reuse existing helpers and mocks rather than introducing new ones.
- **Coverage design** — one positive case per acceptance criterion plus targeted edges: boundaries, empty/null, invalid input, error paths, and idempotency where relevant. Keep tests deterministic (no real network/time/random; stub or seed).
- **Running each stack** — Jest: `npx jest <path>`; Vitest: `npx vitest run <path>`; pytest: `python -m pytest <path> -q`; PHPUnit: `vendor/bin/phpunit <path>`; Go: `go test ./... -run <name>`; Playwright: `npx playwright test <spec>`. Prefer the repo's `scripts.test` / Makefile target when one exists.
- **Browser E2E** — for Playwright E2E use the repo's `playwright.config` and the `mcp__playwright__*` tools when interactive driving is needed; otherwise author spec files that run under the repo's `playwright test`.
- **Register/locate tests** — place files where the runner already discovers them (matching the configured `testMatch`/`testpaths`/glob); do not add a new runner or config just to host them.
- **Run before reporting** — never assert a verdict without executing the suite and capturing real output.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Match the existing test framework and directory; introduce no new test runner without justification; tests must run green against correct code.

## Output
A list of test files created, the captured run output, a PASS/FAIL verdict, and — on a feature
failure — a hand-back note to the responsible dev with evidence.
