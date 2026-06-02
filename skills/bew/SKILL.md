---
name: bew
description: Use when building React or Next.js UI — components, hooks, routing, data fetching, performance.
---

# Bew — React / Next.js Engineering

Bew (บิว) is the React / Next.js developer of the Only CNX team. This skill provides the craft for
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

> Shared team baseline (DoD, review culture, Context7 reflex, secret safety) lives in the `engineering-practices` skill — load it alongside this one.

## Decision rules
- **Server vs client component** → needs state/effects/event handlers/browser APIs? → add `'use client'` on the smallest leaf. Otherwise keep it a Server Component.
- **Where to fetch** → server-owned data or anything needing secrets → fetch in a Server Component / route handler. Interactive, per-user, frequently-changing data → client cache (`react-query`/SWR), never a hand-rolled `useEffect` fetch.
- **Effect or not** → value derivable from props/state → compute during render (no effect). Only use an effect to sync with an external system (subscriptions, non-React widgets).
- **Memoize?** → only after a measured re-render cost or a referential-identity bug. Not by default.
- **Unfamiliar/changed API** (React 19 `use`, server actions, App Router caching, Next 15) → run the Context7 docs check before writing it.

## Anti-patterns
- **Top-level `'use client'`** — smell: directive in a layout/page root, turning the whole subtree into client code → push the boundary down to the interactive leaf.
- **`useEffect` data fetch** — smell: `useEffect(() => { fetch(...) }, [])` → causes waterfalls, no cache, no dedup → server fetch or `react-query`/SWR.
- **Derived state in state** — smell: `useState` mirrored from a prop via an effect → compute during render.
- **Dependency-array lies** — smell: deps omitted to "stop re-runs" → keep deps honest; restructure (move the value, `useCallback`, or a ref) instead.
- **Raw `dangerouslySetInnerHTML`** — smell: user/remote HTML injected unsanitized → sanitize (DOMPurify) or render as text.

## Worked examples
**Derived state — don't mirror, compute:**
```tsx
// ✗ before: extra state + effect, one render behind
const [full, setFull] = useState('');
useEffect(() => { setFull(`${first} ${last}`); }, [first, last]);
// ✓ after: derive during render
const full = `${first} ${last}`;
```
**Client boundary — push it down:**
```tsx
// ✗ before: 'use client' at page top → whole page ships to client
'use client';
export default function Page() { /* static content + one button */ }
// ✓ after: page stays a Server Component; only the button is client
export default function Page() { return (<><Article/><LikeButton/></>); }
// LikeButton.tsx starts with 'use client'
```

## Verification checklist
- [ ] Build + lint pass (captured output).
- [ ] `'use client'` only on interactive leaves, not roots.
- [ ] No `useEffect` fetch where a server fetch or query lib fits.
- [ ] Effect dependency arrays are honest and complete.
- [ ] User-rendered content is escaped/sanitized (no raw `dangerouslySetInnerHTML`).
- [ ] No secret or server-only env reaches the client bundle.

## References
- React docs (react.dev): *You Might Not Need an Effect*, *Rules of Hooks*, `use`.
- Next.js docs: App Router, *Data Fetching & Caching*, Server Actions.
- **Context7:** `resolve-library-id "next.js"` / `"react"` → `get-library-docs` for the exact version in `package.json` before using an unfamiliar or upgraded API.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Never hardcode secrets in client code; sanitize rendered user input (XSS); avoid needless re-renders and duplicate requests.

## Output
Files changed + what changed + how to run + UI notes/screenshots if applicable.
