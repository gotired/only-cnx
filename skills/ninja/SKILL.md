---
name: ninja
description: Use when implementing backend code in TypeScript, PHP, Python, or Go — APIs, services, data access.
---

# Ninja — Backend Engineering

Ninja (นินจา) is the backend developer of the Only CNX team. This skill provides the craft for
implementing correct, secure, and performant backend code across TypeScript, PHP, Python, and Go:
how to detect the stack, write safe data access, define an API contract for hand-offs, and keep
endpoints fast.

## When to use
- Implementing or changing an API endpoint, service, or business logic.
- Writing or reviewing data-access code (queries, repositories, ORMs).
- Defining an API contract for a contract-first hand-off to the frontend.
- Hardening validation, error handling, or backend performance.

## Workflow
1. Read the scope and acceptance criteria.
2. Detect the language/framework from manifest files.
3. Implement the feature as a minimal diff in the project's style.
4. Add input validation and idiomatic error handling.
5. Parameterize every query.
6. Self-verify (build / lint / run) and document the API contract.
7. Return for QA; flag migrations/auth/payments for Tee plus an independent second-opinion review.

## Knowledge / patterns
- **Stack detection** — TypeScript/Node: `package.json` (+ framework deps like express/nestjs/fastify); PHP: `composer.json` (Laravel `artisan`, Symfony `bin/console`); Python: `pyproject.toml` or `requirements.txt` (FastAPI/Django/Flask); Go: `go.mod`. Match the project's existing framework conventions rather than introducing a new one.
- **Parameterized data access (no SQL injection)** — never concatenate user input into SQL. TypeScript: parameterized driver queries (`$1`/`?`) or a query builder/ORM (Prisma, Knex, TypeORM). PHP: PDO prepared statements with bound params, or Eloquent/Doctrine. Python: DB-API params (`%s`/`:name`), SQLAlchemy Core/ORM, or the Django ORM. Go: `database/sql` with `?`/`$1` placeholders or `sqlc`/`sqlx`. Treat ORM raw-query escapes as the exception, always parameterized.
- **Input validation at the boundary** — validate and coerce every external input before use. TS: zod/class-validator; PHP: form requests / validator; Python: pydantic / serializers; Go: validator tags or explicit checks. Reject early with clear 4xx errors; never trust client-supplied IDs for authorization.
- **API contract for contract-first hand-offs** — when frontend (Bew/Oat/Guitar) works in parallel, publish the contract first: method + path, request shape (fields, types, required), response shape (success + error envelope), status codes, pagination/filter params, and auth requirement. Keep it stable; version breaking changes. This unblocks parallel frontend work.
- **Backend performance checklist** — avoid N+1 queries (eager-load / batch / DataLoader); ensure indexes cover query predicates and sort keys; paginate large result sets (cursor over large OFFSET); use connection pooling; bound payload size and select only needed columns; cache only when reused and invalidation is clear.
- **Idiomatic error handling per stack** — TS: typed errors + centralized error middleware, no swallowed promises. PHP: exceptions mapped to HTTP responses, no silent `@`. Python: specific exceptions + handlers, avoid bare `except`. Go: wrap errors with `%w`, return early, never ignore the `err`. Log context without secrets.
- **Transactions & consistency** — wrap multi-write operations in a transaction with the narrowest scope; make external-effect endpoints idempotent; flag schema migrations as critical work for Tee review plus an independent second-opinion review.
- **Import-safe entrypoint (testability)** — separate app/server construction from binding: export a `createApp()`/`createServer()` factory and only call `listen()` under a main-module guard (`if (require.main === module)` in CJS, `if (import.meta.url === \`file://${process.argv[1]}\`)` in ESM, or the framework's run target). This lets QA import and test the app in-process without spawning a subprocess or binding a port.

> Shared team baseline (DoD, review culture, Context7 reflex, secret safety) lives in the `engineering-practices` skill — load it alongside this one.

## Decision rules
- **Trust this input?** → never. Validate and coerce every external value at the boundary before use; never trust a client-supplied ID for authorization (check ownership server-side).
- **Raw SQL or builder?** → either is fine *parameterized*; string interpolation of user input is never fine. ORM raw escape is the rare exception, still bound.
- **Wrap in a transaction?** → two or more writes that must succeed together → yes, narrowest scope. Single write → no.
- **Is this critical work?** → migrations, auth, authz, payments, anything touching schema or money → flag for Tee plus an independent second-opinion review before "done".
- **Breaking a contract?** → additive change → fine; removing/renaming a field or changing status semantics → version it and notify consumers.
- **Unfamiliar/changed framework API** (a new ORM, a framework major bump) → Context7 docs check before writing it.

## Anti-patterns
- **String-concatenated SQL** — smell: `` `WHERE id = ${id}` `` → parameterize (`$1`/`?`/named binds).
- **Trusting the client's id** — smell: `DELETE WHERE id = req.body.id` with no ownership check → scope by the authenticated principal.
- **N+1 queries** — smell: a query inside a `.map`/loop over rows → eager-load / batch / `DataLoader`.
- **Swallowed errors** — smell: bare `except:` / empty `catch` / ignored Go `err` → handle or wrap (`%w`) and surface.
- **Unbounded result sets** — smell: `SELECT *` with no limit feeding a list endpoint → paginate (cursor over large OFFSET), select needed columns.
- **Fat transaction** — smell: external HTTP call inside a DB transaction → keep the transaction tight; do side effects outside it.

## Worked examples
**Parameterize the query:**
```ts
// ✗ before — SQL injection
db.query(`SELECT * FROM users WHERE email = '${email}'`);
// ✓ after — bound parameter
db.query('SELECT * FROM users WHERE email = $1', [email]);
```
**Validate at the boundary (zod):**
```ts
// ✓ reject early with a clear 4xx, then trust the typed value
const Body = z.object({ qty: z.number().int().positive() });
const { qty } = Body.parse(req.body);
```

## Verification checklist
- [ ] Build + lint/type-check + relevant tests run green (captured output).
- [ ] Every external input validated/coerced at the boundary.
- [ ] Every query parameterized; no string-built SQL.
- [ ] Authorization checks ownership, not just authentication.
- [ ] Multi-write paths are transactional and external-effect endpoints idempotent.
- [ ] API contract documented (shape, status codes, error envelope) for consumers.
- [ ] Migrations/auth/payments flagged for Tee plus an independent second-opinion review.
- [ ] Server entrypoint is import-safe — no side-effect `listen()` on import (factory exported).

## References
- OWASP: *SQL Injection Prevention*, *Input Validation*, *Authorization* cheat sheets.
- Framework docs for the detected stack (NestJS/Express, Laravel/Symfony, FastAPI/Django, Go `database/sql`).
- **Context7:** `resolve-library-id` for the ORM/framework in the manifest → `get-library-docs` before using an unfamiliar or upgraded API.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Parameterize all queries; validate all inputs; never log secrets; flag migrations/auth/payments for Tee review plus an independent second-opinion review.

## Output
Files changed + what changed + how to run/test + any API contract (shape) exposed for the frontend.
