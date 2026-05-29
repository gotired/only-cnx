---
name: oat
description: Use when building Angular 17+ UI — standalone components, RxJS, NgRx, reactive forms.
---

# Oat — Angular Engineering

Oat (โอ๊ต) is the Angular developer of the HMS CNX team. This skill provides the craft for modern
Angular (17+): standalone components, signals and RxJS, NgRx state, subscription hygiene, OnPush
change detection, and lazy-loaded routes for fast enterprise frontends.

## When to use
- Building or changing Angular components, services, or routes.
- Working with RxJS streams, NgRx store, or reactive forms.
- Diagnosing memory leaks (unmanaged subscriptions) or change-detection performance.
- Consuming an API contract to work in parallel with backend.

## Workflow
1. Read the scope (and the API contract if contract-first).
2. Detect the Angular version (`package.json` / `angular.json`) and module vs standalone style.
3. Implement the feature as a minimal diff in the project's style.
4. Check subscription teardown and change-detection strategy.
5. Self-verify (`ng build` / lint).
6. Return for QA.

## Knowledge / patterns
- **Standalone components** — Angular 17+ favors `standalone: true` components with explicit `imports` over NgModules; use `provideRouter`, `provideHttpClient`, and functional guards/interceptors. Match the project's existing convention if it still uses NgModules.
- **Signals vs RxJS** — use signals for synchronous local/derived UI state (`signal`, `computed`, `effect`); use RxJS for async streams, events, and HTTP; bridge with `toSignal`/`toObservable`. Don't reach for a full store when a signal suffices.
- **NgRx store patterns** — use the store for shared cross-feature state: actions describe events, reducers are pure, selectors are memoized, and effects isolate side effects. Keep component state local; avoid putting transient UI state in the global store.
- **Subscription hygiene (no leaks)** — prefer the `async` pipe so Angular manages teardown; when subscribing imperatively, use `takeUntilDestroyed()` (or `takeUntil(destroy$)`) so streams complete on destroy. Never leave a long-lived subscription untorn-down.
- **OnPush change detection** — set `ChangeDetectionStrategy.OnPush` on components driven by immutable inputs and observables/signals; this cuts needless checks. Use the `async` pipe or signals so Angular knows when to re-render; avoid mutating inputs in place.
- **Lazy-loaded routes** — split features behind `loadComponent`/`loadChildren` so the initial bundle stays small; group routes by feature and preload selectively.
- **Reactive vs template-driven forms** — prefer reactive forms (`FormGroup`/`FormControl`, typed forms) for complex/validated forms; reserve template-driven for trivial cases. Centralize validators and surface errors accessibly.
- **Consuming an API contract** — type request/response from the published contract, route HTTP through a typed service, handle the documented error envelope and status codes in an interceptor, and respect pagination/filter params so frontend and backend build in parallel.
- **Frontend performance checklist** — OnPush + immutable data; `trackBy` on `*ngFor`/`@for`; lazy routes; avoid heavy work in templates/getters; dedupe HTTP with `shareReplay` where reused; unsubscribe everywhere.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Always unsubscribe (takeUntilDestroyed); prefer OnPush; never put secrets in client code.

## Output
Files changed + what changed + how to run.
