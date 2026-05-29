---
name: <kebab-id>
type: contract
title: <method + path | interface name>
project: <repo-name | "*">
status: active            # active | superseded | deprecated
version: v1
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [<stack/area>]
related: []
---

# <method + path | interface name>

- **Request** — fields, types, required vs optional.
- **Response** — success shape + the error envelope.
- **Status codes** — success + documented error codes.
- **Auth** — requirement (none / token / role).
- **Owner / consumers** — the producer, and who depends on it.
- **Versioning** — current version; breaking-change policy (version, don't mutate in place).
