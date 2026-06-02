---
name: oat
description: Use when building Angular 17+ UI — standalone components, RxJS, NgRx, reactive forms.
---

# Oat — Angular Engineering

Oat (โอ๊ต) is the Angular developer of the Only CNX team. This skill provides the craft for modern
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

> Shared team baseline (DoD, review culture, Context7 reflex, secret safety) lives in the `engineering-practices` skill — load it alongside this one.

## Decision rules
- **Signal or RxJS?** → synchronous local/derived UI state → `signal`/`computed`. Async streams, events, HTTP → RxJS. Bridge with `toSignal`/`toObservable`.
- **Global store or local?** → state shared across features → NgRx. Transient/component-only UI state → keep it local; don't globalize it.
- **How do I read this stream in the template?** → prefer the `async` pipe (auto-teardown). Imperative subscribe → must pair with `takeUntilDestroyed()`.
- **OnPush?** → component driven by immutable inputs + observables/signals → yes. Mutating inputs in place → fix that first, then OnPush.
- **Standalone or module?** → new code in 17+ → standalone + `provide*` functions, unless the project still uses NgModules (match it).
- **Unfamiliar/changed API** (signals, control flow `@if`/`@for`, Angular major bump) → Context7 docs check first.

## Anti-patterns
- **Unmanaged subscription** — smell: `.subscribe(...)` with no teardown → memory leak → `async` pipe or `takeUntilDestroyed()`.
- **Nested subscribe** — smell: `.subscribe(x => inner$.subscribe(...))` → flatten with `switchMap`/`mergeMap`/`concatMap`.
- **Default change detection on heavy trees** — smell: large component re-checking on every tick → `OnPush` + immutable data.
- **Logic in the template** — smell: method calls/getters in bindings recomputed each cycle → precompute in a `computed`/field.
- **Promise where a stream fits** — smell: `await` of an HTTP call that should compose with other streams → keep it observable.
- **Global store for local state** — smell: a form's transient value in NgRx → keep it in the component.

## Worked examples
**Subscription hygiene:**
```ts
// ✗ before — leaks on destroy
ngOnInit() { this.svc.data$.subscribe(d => this.d = d); }
// ✓ after — auto-torn-down
private destroyRef = inject(DestroyRef);
ngOnInit() { this.svc.data$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe(d => this.d = d); }
// ✓ better — no manual subscribe at all, async pipe in template: {{ d$ | async }}
```
**Flatten instead of nesting:**
```ts
// ✗ before
this.id$.subscribe(id => this.api.get(id).subscribe(...));
// ✓ after
this.detail$ = this.id$.pipe(switchMap(id => this.api.get(id)));
```

## Verification checklist
- [ ] `ng build` + lint pass (captured output).
- [ ] No imperative subscribe without `takeUntilDestroyed()` (prefer `async` pipe).
- [ ] No nested `subscribe` (flattened with the right higher-order operator).
- [ ] `OnPush` on components driven by immutable inputs/streams; no in-place input mutation.
- [ ] `trackBy` on list rendering; no heavy work in template bindings.
- [ ] API contract typed; errors handled in an interceptor; no secrets in client code.

## References
- Angular docs (angular.dev): Signals, Control Flow, *Standalone components*, Change Detection.
- RxJS docs: higher-order mapping operators (`switchMap`/`mergeMap`/`concatMap`/`exhaustMap`).
- **Context7:** `resolve-library-id "angular"` / `"@ngrx/store"` → `get-library-docs` for the version in `package.json` before using an unfamiliar or upgraded API.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Always unsubscribe (takeUntilDestroyed); prefer OnPush; never put secrets in client code.

## Output
Files changed + what changed + how to run.
