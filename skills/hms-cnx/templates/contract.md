# API Contract (dispatch stub) — <name>

> A frozen interface so producer + consumers build in parallel. Distinct from the durable
> `team-memory` contract note — this one lives in `.hms-cnx/run/contracts/` during a run.

- **Endpoint:** <METHOD> <path>
- **Request:** <fields, types, required vs optional>
- **Response (success):** <status code> + <body shape>
- **Response (errors):** <status code(s)> + <error envelope shape>
- **Auth:** <required? how>
- **Pagination/filter:** <params, or "n/a">
- **Notes:** <idempotency, versioning, side effects>
