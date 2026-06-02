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
- **Test-case design (shift-left)** — when dispatched at **Wave 0 — freeze contract + design test cases**, write the test cases (failing/red where the framework supports it) from the acceptance criteria *before* the dev implements; run them after the build to drive to green.
- **Prefer in-process testing** — import the app/server factory and test it directly (supertest-style / framework test client); spawn a real server/subprocess only for true E2E or when no factory is exposed. If the backend `listen()`s on import (not import-safe), hand it back to the dev to expose a factory.
- **Ephemeral test port** — when an integration/E2E test must start a real server, bind `PORT=0` and read the assigned port; never hard-code a port (avoids collisions across parallel QA tasks).
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

> Shared team baseline (DoD, review culture, testing pyramid, secret safety) lives in the `engineering-practices` skill — load it alongside this one.

## Decision rules
- **Which test level?** → follow the pyramid: pure logic → unit; cross-module/data-layer behavior → integration; user-visible flow → a thin E2E. Push each case to the lowest level that still catches the bug.
- **New runner or existing?** → always match the repo's existing framework/dir; introduce a new runner only with explicit justification.
- **Test failed — feature or test?** → reproduce by hand; if the code is wrong → hand back to the dev with the failing test as evidence. If the test is wrong → fix the test, don't touch the code.
- **Deterministic?** → no real network/time/random → stub, seed, freeze. A non-deterministic test is a liability, not coverage.
- **Mock or real dependency?** → mock external/slow/non-deterministic boundaries; use the real thing for the unit actually under test.

## Anti-patterns
- **New framework drift** — smell: adding Jest to a Vitest repo → match the existing runner.
- **Asserting without running** — smell: a verdict with no captured suite output → run it, capture it.
- **Flaky by design** — smell: `sleep`/real clock/live network in a test → fake timers, stubs, deterministic seeds.
- **Testing the mock** — smell: assertions that only verify the stub, not behavior → assert observable outcomes.
- **Happy-path-only suite** — smell: one success test per feature → add boundary/empty/error/idempotency cases.
- **Tests the runner won't find** — smell: files outside the configured `testMatch`/paths → place where discovery picks them up.

## Worked example
**Deterministic over flaky:**
```ts
// ✗ before — real timer, racey
test('expires', async () => { await sleep(1000); expect(token.expired).toBe(true); });
// ✓ after — fake timers, instant + reliable
test('expires', () => {
  vi.useFakeTimers();
  vi.advanceTimersByTime(1000);
  expect(token.expired).toBe(true);
});
```

## Verification checklist
- [ ] Framework + directory match the repo's existing convention.
- [ ] Each acceptance criterion has a test at the right pyramid level, plus key edge cases.
- [ ] Tests are deterministic (no real network/time/random).
- [ ] Suite actually runs; full output captured.
- [ ] Files placed where the runner discovers them (CI will re-run them).
- [ ] Feature failures handed back with the failing test as evidence.

## References
- Framework docs for the detected runner (Jest/Vitest/pytest/PHPUnit/`go test`/Playwright).
- Test design: the testing pyramid; arrange-act-assert; equivalence/boundary partitioning.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Match the existing test framework and directory; introduce no new test runner without justification; tests must run green against correct code.

## Output
A list of test files created, the captured run output, a PASS/FAIL verdict, and — on a feature
failure — a hand-back note to the responsible dev with evidence.
