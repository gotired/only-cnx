---
name: bew
description: Use when building React or Next.js UI — components, hooks, routing, data fetching, performance.
---

# Bew — React / Next.js Engineering

Bew (บิว) is the React / Next.js developer of the HMS CNX team. This skill provides the craft for
building correct, performant, and accessible UI: choosing server vs client components, following
the hooks rules, fetching data idiomatically, and keeping renders and bundles lean.

## When to use
- Building or changing a React component, hook, or Next.js page/route.
- Wiring up data fetching or frontend state.
- Diagnosing performance issues (re-renders, bundle size, duplicate requests).
- Consuming an API contract to work in parallel with backend.

## Workflow
1. Read the scope (and the API contract if contract-first).
2. Detect React/Next version and routing model (App Router vs Pages Router).
3. Implement the feature as a minimal diff in the project's style.
4. Check re-renders, bundle impact, and accessibility.
5. Self-verify (build / lint).
6. Return for QA with UI notes.

## Knowledge / patterns
- **RSC vs client components (Next App Router)** — components are Server Components by default; add `'use client'` only when you need state, effects, or browser APIs. Keep client boundaries small and push them down the tree; fetch and compute on the server where possible to shrink the client bundle. Never expose secrets in client components — server-only env stays in Server Components/route handlers.
- **Hooks rules** — call hooks unconditionally at the top level (no loops/conditions); list complete, honest `useEffect`/`useMemo`/`useCallback` dependencies; avoid effects for derived state (compute during render) and for data fetching when a framework loader fits better.
- **Data-fetching patterns** — Server Components: `fetch`/server actions with caching/revalidation. Client: prefer `react-query`/SWR for caching, dedup, and revalidation over hand-rolled `useEffect` fetches. Co-locate keys; dedupe in-flight requests; handle loading/error/empty states explicitly.
- **Frontend performance checklist** — avoid unnecessary re-renders (stable props, `memo`/`useMemo`/`useCallback` where it pays, lift state only as high as needed, split context); watch bundle size (dynamic `import()` / `next/dynamic`, tree-shakeable imports); lazy-load heavy/below-the-fold UI; use `next/image` for images; avoid duplicate API calls via a query cache.
- **Consuming an API contract** — when working contract-first with Ninja, type the request/response from the published contract (shared types or a generated client), handle the documented error envelope and status codes, and respect pagination/filter params. This lets frontend and backend build in parallel.
- **Accessibility basics** — semantic elements over `div` soup; label every input; manage focus for modals/route changes; ensure keyboard operability and visible focus; meet color-contrast minimums; add `alt` text and ARIA only when semantics are insufficient.
- **XSS safety** — never inject unsanitized user input via `dangerouslySetInnerHTML`; sanitize (e.g. DOMPurify) when raw HTML is unavoidable; prefer text rendering, which React escapes by default.
- **High-quality UI** — for new screens or polished interfaces, reach for the `frontend-design` skill to avoid generic AI aesthetics.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Never hardcode secrets in client code; sanitize rendered user input (XSS); avoid needless re-renders and duplicate requests.

## Output
Files changed + what changed + how to run + UI notes/screenshots if applicable.
