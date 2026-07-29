# Tech Spec — Anima

## Current Technical Summary

| | |
|---|---|
| Runtime / framework | Godot 4.3 (GDScript), addon under `addons/` |
| Language | GDScript |
| Data / storage | None — motions are in-memory Resource objects; no persistence layer |
| Main interfaces | `Anima.play(motion, node = null)` runtime playback entry point; typed `AnimaMotion` Resource hierarchy; `Motion` static builder as an alternative authoring surface |
| Testing | GUT ([bitwes/Gut](https://github.com/bitwes/Gut)) — already installed and enabled as an editor plugin; the project's committed test runner (see `project-rules.md` §Testing for coverage expectations) |
| Key constraints | No mandatory autoload; the legacy v0.x implementation has been removed from the repository entirely (not kept alongside) |

## Tech stack

Godot 4.3, GDScript only. No GDExtension/native code in Phase 1 — see Out of Scope for the native-accelerator gate criteria.

## Libraries & dependencies

| Category | Decision | Why | Install |
|----------|----------|-----|---------|
| Core runtime | None — pure GDScript, Godot 4.3 stdlib | No external dependency needed for resource composition + a per-frame loop | n/a |
| Testing | GUT ([bitwes/Gut](https://github.com/bitwes/Gut)), already installed at `addons/gut` | Matches the existing project's test convention; avoids a second test runner | Already present |

## Data model

| Entity | Fields | Notes |
|--------|--------|-------|
| `AnimaMotion` (base) | `display_name: String`, `enabled: bool`, `delay: float`, `delay_basis: AFTER_PREVIOUS_ENDS \| AFTER_PREVIOUS_STARTS` (default `AFTER_PREVIOUS_ENDS`), `speed: float`, `tags: Array[String]`, `metadata: Dictionary` | Base Resource every composite/leaf extends. Contract: `estimate_duration() -> AnimaDuration` / `create_runtime()` / `validate()`. Defaults: `delay = 0.0`, `speed = 1.0`. `tags` is optional categorisation metadata — no logic reads or filters on it. `delay` may be negative (an overlap); `delay_basis` picks which sibling instant it's relative to (see Key technical decisions). Only `AnimaSequence` consumes `delay`/`delay_basis` this phase. |
| `AnimaDuration` | `kind: FIXED \| ESTIMATED \| DYNAMIC \| INFINITE`, `seconds: float` (meaningful for `FIXED`/`ESTIMATED`; `0.0` and unused for `DYNAMIC`/`INFINITE`) | Return type of `estimate_duration()`. Replaces the Phase 1 plain-`float` contract (see ⚠️ Note). |
| `AnimaSequence` (composite) | `children: Array[AnimaMotion]` | Completes when the last enabled child completes. Each child's effective start now honours its own `delay`/`delay_basis` — see Key technical decisions. |
| `AnimaParallel` (composite) | `children: Array[AnimaMotion]`, `completion_policy: ALL_CHILDREN \| FIRST_CHILD \| NAMED_CHILD` (default `ALL_CHILDREN`), `completion_child_name: String` | Default mirrors Sequence's "wait for everything" behaviour; narrower policies are an explicit opt-in. Does not consume `delay`/`delay_basis` this phase. |
| `AnimaStagger` (composite) | `template: AnimaMotion`, `targets: Array[Node]`, `interval: float` (default `0.05`), `order: FORWARD \| REVERSE \| FROM_CENTER \| FROM_EDGES \| RANDOM \| CUSTOM` (default `FORWARD`), `custom_order: Array[int]` (used only when `order = CUSTOM`; explicit target indices) | One `template` instance is created per entry in `targets`, started `interval` seconds apart in the resolved order. Ignores the `target` passed to its own `advance()` — see Key technical decisions. |
| `AnimaRepeat` (composite) | `child: AnimaMotion`, `count: int` (default `1`), `delay_between: float` (default `0.0`), `alternate: bool` (default `false`) | `count` is always finite this phase (see Out of Scope). When `alternate` is `true` and `child` is an `AnimaPropertyMotion`, odd iterations swap `from_value`/`to_value`; reversing a composite `child` is not defined this phase (see Out of Scope). |
| `AnimaRace` (composite) | `children: Array[AnimaMotion]`, `cancel_remaining: bool` (default `true`) | Completes as soon as the fastest child finishes. "Cancel" means the runtime stops advancing the other children's instances — the same mechanism `AnimaParallel`'s `FIRST_CHILD`/`NAMED_CHILD` policies already use, never `AnimaPlayback.cancel()` (children have no playback of their own). Setting `cancel_remaining = false` has no defined effect this phase. |
| `AnimaConditional` (composite) | `when_true: AnimaMotion`, `when_false: AnimaMotion`, `condition: Callable` (zero-arg, returns `bool`), `resolution_timing: COMPILE_TIME \| RUNTIME` (default `RUNTIME`) | `COMPILE_TIME`: `estimate_duration()` calls `condition` immediately and returns the selected branch's own `AnimaDuration`. `RUNTIME` (default, safer): `estimate_duration()` returns `Kind.DYNAMIC` without calling `condition`; the branch is selected once, inside `create_runtime()`, and that branch's instance drives `advance()` from then on. |
| `AnimaPropertyMotion` (leaf) | `target_property: NodePath`, `from_value: Variant` (null = read current value at start), `to_value: Variant`, `duration: float`, `ease: AnimaEase` (default: new `AnimaEase` with `kind = LINEAR`) | Only leaf type. Reads/writes the target via Godot's built-in `set`/`get`. New chainable methods: `.duration(value: float) -> AnimaPropertyMotion`, `.ease(value: AnimaEase) -> AnimaPropertyMotion` (each sets the field and returns `self`, for the builder API). |
| `AnimaEase` | `kind: LINEAR \| POLYNOMIAL \| SINE \| EXPONENTIAL \| CIRCULAR`, `exponent: float` (default `2.0`, used only when `kind = POLYNOMIAL`) | Basic curve set only — spring, decay, cubic Bézier, curve resource, callable evaluator, and custom sampled curve are deferred. `evaluate(t: float) -> float` is the shared contract every kind implements. |
| `AnimaPlayback` | `motion: AnimaMotion`, `target: Node`, `state: PLAYING \| PAUSED \| CANCELLED \| FINISHED`, `finished` (Signal) | Returned by `Anima.play()`. Methods: `pause()` → `PAUSED`, animated values freeze in place; `resume()` → `PLAYING` from the paused position; `cancel()` → `CANCELLED`, resolves `finished` as not-success. `finished` fires exactly once, on `FINISHED` or `CANCELLED`. |
| `AnimaRuntime` | `active_playbacks: Array[AnimaPlayback]` | Lazily created on the first `Anima.play()` call; owns the central per-frame evaluation loop. No `project.godot` autoload entry required. |
| `Anima` (entry point) | static `play(motion: AnimaMotion, target: Node = null) -> AnimaPlayback` | Thin static facade; delegates to `AnimaRuntime`. Declared via `class_name Anima`, not an autoload. `target` is now optional — omit it when the top-level motion supplies its own targets (`AnimaStagger`); every other motion type still requires it. |
| `Motion` (builder) | static factories: `sequence(children: Array[AnimaMotion]) -> AnimaSequence`, `parallel(children: Array[AnimaMotion]) -> AnimaParallel`, `stagger(targets: Array[Node], template: AnimaMotion, interval: float) -> AnimaStagger`, `repeat(child: AnimaMotion, count: int) -> AnimaRepeat`, `race(children: Array[AnimaMotion]) -> AnimaRace`, `conditional(condition: Callable, when_true: AnimaMotion, when_false: AnimaMotion) -> AnimaConditional`, `to(target_property: NodePath, to_value: Variant) -> AnimaPropertyMotion` | Thin factory + chaining layer over the existing resource model — builds the same resources direct construction does, nothing new at runtime. Takes an `Array[AnimaMotion]` for multi-child factories rather than variadic arguments (GDScript has no true variadics); this is a deliberate divergence from the PRD's illustrative comma-separated syntax. No named presets (`fade_in`, etc.) this phase — see Out of Scope. |

Test data: a demo scene with one Control/Node2D node and 2-3 `AnimaPropertyMotion` leaves composed via Sequence/Parallel is enough to verify every Phase 1 Exit Criterion. Phase 3 needs a scene with several nodes (for `AnimaStagger`'s `targets` and `AnimaRace`/`AnimaConditional` branches) — this is what the phase's own example-scene item builds.

## Storage strategy

None in Phase 1. Motions are constructed and held as in-memory Resource objects. If a developer chooses to save one as a `.tres`, that's Godot's own resource-saving mechanism, not something Anima adds.

## Key technical decisions

- Every motion type extends `AnimaMotion`; the scheduler treats Sequence/Parallel/Property polymorphically through `estimate_duration()` / `create_runtime()` / `validate()` — no type-specific branching in the scheduler itself.
- One central per-frame evaluation loop advances all active playbacks (not one Tween per property), per the phase brief's principle.
- No per-property ownership tracking in Phase 1: if two active motions write the same node property, the later per-frame write wins. Deliberately unguarded until the deferred ownership-tracking backlog item lands.
- No interruption policy in Phase 1: calling `Anima.play()` again on a node with an existing playback starts an independent second playback; nothing auto-cancels the first. Any resulting property conflict falls under the last-write-wins rule above.
- The legacy v0.x implementation (`addons/anima/core`, `addons/anima/utils`, `addons/anima/animations`, its demos, and its tests) has been deleted from the repository rather than kept alongside the new implementation — a deliberate, accepted breaking change for external projects still depending on the installed v0.x addon. It remains recoverable from git history if ever needed for reference. `AnimaLegacy` is still reserved for the deferred dictionary-compatibility shim (a separate, not-yet-built class) and is unaffected by this removal.
- Duration-kind combining rule for any composite with more than one duration-contributing source (`AnimaSequence`, `AnimaParallel` under `ALL_CHILDREN`, `AnimaStagger`, `AnimaRepeat`, `AnimaRace`): the worst kind wins, in priority order `INFINITE > DYNAMIC > ESTIMATED > FIXED`. Once every source is `FIXED`, each composite has its own numeric rule for `seconds` — the shape of the composite decides whether that's a sum, a max, or a min, not one shared formula:
  - `AnimaSequence` (serial): sum of children's `seconds`.
  - `AnimaParallel`/`ALL_CHILDREN` (concurrent, waits for slowest): max of children's `seconds`.
  - `AnimaRepeat` (serial repetition): `count × child.seconds + (count - 1) × delay_between`.
  - `AnimaStagger` (concurrent, offset starts — every target runs the same `template`, so its kind is simply the template's kind): `(targets.size() - 1) × interval + template.seconds`. Not a sum of per-target durations — a literal sum would overstate the composition's actual wall-clock length, since targets start staggered rather than end-to-end.
  - `AnimaRace` (concurrent, completes on the fastest child): min of children's `seconds`.
  `AnimaParallel` under `FIRST_CHILD`/`NAMED_CHILD`, and `AnimaConditional`, instead defer entirely to one specific child/branch's own `AnimaDuration` — no combining.
- `AnimaSequence` child timing: a child's effective start is `delay` seconds after either the previous child's end (`delay_basis = AFTER_PREVIOUS_ENDS`, the default — a negative `delay` is an overlap) or the previous child's start (`AFTER_PREVIOUS_STARTS`). The first child has no predecessor, so both bases resolve to "relative to the sequence's own start" for it.
- `AnimaStagger` ignores the `target` argument its own `advance()` receives; it drives each entry in its own `targets` array through its own instance of `template.create_runtime()` instead. This is why `Anima.play()`'s `target` parameter became optional — a top-level `AnimaStagger` doesn't need one.
- `AnimaRace`/`AnimaParallel` "cancelling" a losing child never goes through `AnimaPlayback.cancel()` — children are internal instances with no playback of their own; cancelling means the runtime simply stops calling `advance()` on that instance, identical to how `AnimaParallel`'s narrower completion policies already work.

## Out of Scope

- No GDExtension/native-code accelerator. Reconsidered only once all three hold: a reproducible benchmark shows a significant bottleneck in Anima's own evaluation loop (not property writes/layout), a native implementation would meaningfully help, and build/release automation covers the needed platforms. Not built in the initial release; GDScript remains the fallback.
- No dedicated animated-node subclasses (`AnimatedButton`, `AnimatedPanel`, etc.) — Anima always attaches to ordinary nodes.
- No mandatory `project.godot` autoload entry for the runtime to function.
- No target-collection/selector system (`AnimaTargetSelector` or similar) — `AnimaStagger` takes a plain `targets: Array[Node]` this phase; resolving targets from a group, grid, or other dynamic source is a separate, later backlog item.
- No named motion presets (`fade_in`, `tada`, etc.) in the builder API — `Motion` only exposes generic factories this phase; presets are a separate, later backlog item.
- `AnimaParallel` does not consume `delay`/`delay_basis` this phase — only `AnimaSequence` does.
- `AnimaRepeat`'s `alternate` mode is defined only for an `AnimaPropertyMotion` child (swaps `from_value`/`to_value` on odd iterations); reversing a composite child (`AnimaSequence`, `AnimaParallel`, etc.) under `alternate` is undefined until the separate reversibility epic lands.
- `AnimaRace.cancel_remaining = false` has no defined effect — the field exists for future extensibility only.

## Platform constraints

Supported Godot range: 4.3 through the latest stable 4.x release. Godot 3.x is unsupported. No formal LTS-style deprecation window pre-1.0 — if a future 4.x minor requires a breaking change on Anima's side, the minimum version is bumped and noted in the changelog rather than maintained across both. No mobile/web/platform-specific behaviour in Phase 1.

## Product principle constraints

- **Relationships before timestamps** — the scheduler resolves relative structure (Sequence/Parallel) into per-frame values; no public API accepts an absolute start time.
- **Composition over inheritance** — `AnimaMotion` and its subtypes are Resources played against ordinary nodes via `Anima.play()`; nothing subclasses `Node`.

⚠️ Note: `estimate_duration()` now returns `AnimaDuration` (a kind + seconds), replacing Phase 1's plain-`float` contract. `AnimaPropertyMotion` always reports `FIXED`. `AnimaConditional` reports `DYNAMIC` unless `resolution_timing = COMPILE_TIME`. No leaf reports `ESTIMATED` or `INFINITE` yet — those remain reserved for spring easing and true infinite repeat, both still deferred.
