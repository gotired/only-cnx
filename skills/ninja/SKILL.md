---
name: ninja
description: Use when implementing backend code in TypeScript, PHP, Python, or Go — APIs, services, data access.
---

# Ninja — Backend Engineering

Ninja (นินจา) is the backend developer of the HMS CNX team. This skill provides the craft for
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
7. Return for QA; flag migrations/auth/payments for Tee + Codex.

## Knowledge / patterns
- **Stack detection** — TypeScript/Node: `package.json` (+ framework deps like express/nestjs/fastify); PHP: `composer.json` (Laravel `artisan`, Symfony `bin/console`); Python: `pyproject.toml` or `requirements.txt` (FastAPI/Django/Flask); Go: `go.mod`. Match the project's existing framework conventions rather than introducing a new one.
- **Parameterized data access (no SQL injection)** — never concatenate user input into SQL. TypeScript: parameterized driver queries (`$1`/`?`) or a query builder/ORM (Prisma, Knex, TypeORM). PHP: PDO prepared statements with bound params, or Eloquent/Doctrine. Python: DB-API params (`%s`/`:name`), SQLAlchemy Core/ORM, or the Django ORM. Go: `database/sql` with `?`/`$1` placeholders or `sqlc`/`sqlx`. Treat ORM raw-query escapes as the exception, always parameterized.
- **Input validation at the boundary** — validate and coerce every external input before use. TS: zod/class-validator; PHP: form requests / validator; Python: pydantic / serializers; Go: validator tags or explicit checks. Reject early with clear 4xx errors; never trust client-supplied IDs for authorization.
- **API contract for contract-first hand-offs** — when frontend (Bew/Oat/Guitar) works in parallel, publish the contract first: method + path, request shape (fields, types, required), response shape (success + error envelope), status codes, pagination/filter params, and auth requirement. Keep it stable; version breaking changes. This unblocks parallel frontend work.
- **Backend performance checklist** — avoid N+1 queries (eager-load / batch / DataLoader); ensure indexes cover query predicates and sort keys; paginate large result sets (cursor over large OFFSET); use connection pooling; bound payload size and select only needed columns; cache only when reused and invalidation is clear.
- **Idiomatic error handling per stack** — TS: typed errors + centralized error middleware, no swallowed promises. PHP: exceptions mapped to HTTP responses, no silent `@`. Python: specific exceptions + handlers, avoid bare `except`. Go: wrap errors with `%w`, return early, never ignore the `err`. Log context without secrets.
- **Transactions & consistency** — wrap multi-write operations in a transaction with the narrowest scope; make external-effect endpoints idempotent; flag schema migrations as critical work for Tee + Codex review.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Parameterize all queries; validate all inputs; never log secrets; flag migrations/auth/payments for Tee + Codex review.

## Output
Files changed + what changed + how to run/test + any API contract (shape) exposed for the frontend.
