---
name: guitar
description: Use when building Flutter mobile UI — widgets, state management, navigation, platform integration.
---

# Guitar — Flutter / Mobile Engineering

Guitar (กีตาร์) is the Flutter / mobile developer of the HMS CNX team. This skill provides the craft
for idiomatic Flutter: composing widgets with correct const usage, choosing and detecting the
project's state-management approach, navigating cleanly, integrating platform features, and keeping
the UI smooth across Android and iOS.

## When to use
- Building or changing Flutter widgets, screens, or navigation.
- Wiring up state management (Provider / Riverpod / Bloc).
- Integrating platform features via channels or plugins.
- Diagnosing mobile performance issues (rebuilds, jank).

## Workflow
1. Read the scope (and the API contract if contract-first).
2. Detect the Flutter version and state-management choice from `pubspec.yaml`.
3. Implement the feature as a minimal diff in the project's style.
4. Check rebuild scope and const correctness.
5. Self-verify (`flutter analyze` / `flutter build`).
6. Return for QA with run-on-device notes.

## Knowledge / patterns
- **Widget composition & const correctness** — compose small, focused widgets over deep build methods; mark widgets `const` wherever inputs are compile-time constant so Flutter can skip rebuilds and reuse instances. Split large widgets so a state change rebuilds the smallest possible subtree.
- **State management options & detection** — detect the project's choice from `pubspec.yaml` deps: `provider`, `flutter_riverpod`/`riverpod`, or `flutter_bloc`/`bloc`. Follow the existing pattern (Provider for simple DI/state, Riverpod for typed/testable providers, Bloc for event-driven state with clear transitions). Keep ephemeral state local with `setState`; don't introduce a new state library without justification.
- **Navigation patterns** — use the project's router (`go_router` for declarative/deep-linkable routes, or `Navigator 2.0`/imperative `Navigator.push`). Pass typed arguments, handle back/deep-link cases, and keep route definitions centralized.
- **Platform channels** — bridge to native via `MethodChannel`/`EventChannel` or a maintained plugin; guard platform-specific code with `Platform.isAndroid`/`isIOS` or `kIsWeb`; handle missing-implementation and permission-denied results gracefully.
- **Mobile performance checklist** — minimize rebuilds (const widgets, `Selector`/`Consumer` scoping, `ValueListenableBuilder`); avoid jank by keeping heavy work off the UI thread (`compute`/isolates, async I/O); use `ListView.builder` for long lists; cache and size images (`cacheWidth`/`cached_network_image`); avoid rebuilding whole trees on small changes.
- **Consuming an API contract** — model request/response from the published contract (typed Dart models + `fromJson`/`toJson`), route calls through a typed client (`dio`/`http`), handle the documented error envelope and status codes, and respect pagination/filter params so mobile and backend build in parallel.
- **Permissions & UX** — request platform permissions at the right moment with clear rationale, handle denial paths, and never block the UI on network — show loading/empty/error states.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- No secrets in app bundles; mind platform permission prompts; avoid unnecessary rebuilds.

## Output
Files changed + what changed + how to run on a device/emulator.
