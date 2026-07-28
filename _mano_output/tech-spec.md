# Tech Spec — Anima

## Current Technical Summary

| | |
|---|---|
| Runtime / framework | Godot 4.3 (GDScript), addon under `addons/` |
| Language | GDScript |
| Data / storage | None — motions are in-memory Resource objects; no persistence layer |
| Main interfaces | `Anima.play(motion, node)` runtime playback entry point; typed `AnimaMotion` Resource hierarchy |
| Testing | GUT ([bitwes/Gut](https://github.com/bitwes/Gut)) — already installed and enabled as an editor plugin; the project's committed test runner (see `project-rules.md` §Testing for coverage expectations) |
| Key constraints | No mandatory autoload; legacy v1 API renamed `Anima` → `AnimaV1` to free the `Anima` name for the new entry point (see ⚠️ Note) |

## Tech stack

Godot 4.3, GDScript only. No GDExtension/native code in Phase 1 — GDScript remains the fallback until a reproducible benchmark proves the evaluation loop itself is a bottleneck (see Out of Scope).

## Libraries & dependencies

| Category | Decision | Why | Install |
|----------|----------|-----|---------|
| Core runtime | None — pure GDScript, Godot 4.3 stdlib | No external dependency needed for resource composition + a per-frame loop | n/a |
| Testing | GUT ([bitwes/Gut](https://github.com/bitwes/Gut)), already installed at `addons/gut` | Matches the existing project's test convention; avoids a second test runner | Already present |

## Data model

| Entity | Fields | Notes |
|--------|--------|-------|
| `AnimaMotion` (base) | `display_name: String`, `enabled: bool`, `delay: float`, `speed: float`, `tags: Array[String]`, `metadata: Dictionary` | Base Resource every composite/leaf extends. Contract: `estimate_duration()` / `create_runtime()` / `validate()`. Defaults: `delay = 0.0`, `speed = 1.0`. Phase 1: `estimate_duration()` returns a plain seconds value — Fixed only, since Property motion is the only leaf (see ⚠️ Note below). |
| `AnimaSequence` (composite) | `children: Array[AnimaMotion]` | Completes when the last enabled child completes. |
| `AnimaParallel` (composite) | `children: Array[AnimaMotion]`, `completion_policy: ALL_CHILDREN \| FIRST_CHILD \| NAMED_CHILD` (default `ALL_CHILDREN`), `completion_child_name: String` | Default mirrors Sequence's "wait for everything" behaviour; narrower policies are an explicit opt-in. |
| `AnimaPropertyMotion` (leaf) | `target_property: NodePath`, `from_value: Variant` (null = read current value at start), `to_value: Variant`, `duration: float`, `ease: AnimaEase` (default: new `AnimaEase` with `kind = LINEAR`) | Only leaf type in Phase 1. Reads/writes the target via Godot's built-in `set`/`get`. |
| `AnimaEase` | `kind: LINEAR \| POLYNOMIAL \| SINE \| EXPONENTIAL \| CIRCULAR`, `exponent: float` (default `2.0`, used only when `kind = POLYNOMIAL`) | Basic curve set only — spring, decay, cubic Bézier, curve resource, callable evaluator, and custom sampled curve are deferred. `evaluate(t: float) -> float` is the shared contract every kind implements. |
| `AnimaPlayback` | `motion: AnimaMotion`, `target: Node`, `state: PLAYING \| PAUSED \| CANCELLED \| FINISHED`, `finished` (Signal) | Returned by `Anima.play()`. `cancel()` resolves `finished` in the `CANCELLED` state, distinct from normal completion. |
| `AnimaRuntime` | `active_playbacks: Array[AnimaPlayback]` | Lazily created on the first `Anima.play()` call; owns the central per-frame evaluation loop. No `project.godot` autoload entry required. |
| `Anima` (entry point) | static `play(motion: AnimaMotion, target: Node) -> AnimaPlayback` | Thin static facade; delegates to `AnimaRuntime`. Declared via `class_name Anima`, not an autoload — see ⚠️ Note on the legacy rename this requires. |

Test data: a demo scene with one Control/Node2D node and 2-3 `AnimaPropertyMotion` leaves composed via Sequence/Parallel is enough to verify every Exit Criterion in the phase brief.

## Storage strategy

None in Phase 1. Motions are constructed and held as in-memory Resource objects. If a developer chooses to save one as a `.tres`, that's Godot's own resource-saving mechanism, not something Anima adds.

## Key technical decisions

- Every motion type extends `AnimaMotion`; the scheduler treats Sequence/Parallel/Property polymorphically through `estimate_duration()` / `create_runtime()` / `validate()` — no type-specific branching in the scheduler itself.
- One central per-frame evaluation loop advances all active playbacks (not one Tween per property), per the phase brief's principle.
- No per-property ownership tracking in Phase 1: if two active motions write the same node property, the later per-frame write wins. Deliberately unguarded until the deferred ownership-tracking backlog item lands.
- No interruption policy in Phase 1: calling `Anima.play()` again on a node with an existing playback starts an independent second playback; nothing auto-cancels the first. Any resulting property conflict falls under the last-write-wins rule above.
- Legacy `addons/anima/` code and folder layout stay untouched *except* the one rename below — Phase 1's new code still lives in a new, separate module (`addons/anima/motion/`) so the rest of the existing addon keeps working during the transition. Exact file/folder layout is `project-rules.md`'s call, not this spec's.
- Legacy v1 entry point renamed `Anima` → `AnimaV1`: `addons/anima/core/anima.gd`'s `class_name Anima` becomes `class_name AnimaV1`, plus every internal reference to the bare `Anima` identifier across the legacy addon, its existing tests, and the demo scenes is updated to `AnimaV1` so v1 keeps working under its new name. `AnimaLegacy` was considered and rejected as the new name — it's reserved by the deferred dictionary-compatibility shim (`AnimaLegacy.from_dictionary()`), a different, not-yet-built class.

## Out of Scope

- No GDExtension/native-code accelerator — see the deferred "native-accelerator gate" backlog item; only reconsidered after a reproducible benchmark shows Anima's own evaluation loop is the bottleneck.
- No dedicated animated-node subclasses (`AnimatedButton`, `AnimatedPanel`, etc.) — Anima always attaches to ordinary nodes.
- No mandatory `project.godot` autoload entry for the runtime to function.

## Platform constraints

Godot 4.3 target. No mobile/web/platform-specific behaviour in Phase 1.

## Product principle constraints

- **Relationships before timestamps** — the scheduler resolves relative structure (Sequence/Parallel) into per-frame values; no public API accepts an absolute start time.
- **Composition over inheritance** — `AnimaMotion` and its subtypes are Resources played against ordinary nodes via `Anima.play()`; nothing subclasses `Node`.

⚠️ Note: `estimate_duration()` returns a plain float in Phase 1 (Fixed-only, since Property motion is the only leaf type). The deferred Duration-kind model (Fixed/Estimated/Dynamic/Infinite) will need to change this return contract once Dynamic/Infinite leaves (springs, signal waits) ship — flagged in the Phase 1 brief's Assumption Log.

⚠️ Note: `addons/anima/core/anima.gd` already declared `class_name Anima` for the legacy v1 API before this phase started. Godot does not allow two global classes with the same name, and the product decision is to keep `Anima` for the new v2 entry point — so the legacy class is renamed to `AnimaV1` instead (see Key technical decisions). This is a deliberate, accepted breaking change for any *external* project that currently calls `Anima.begin(...)` directly against the installed addon; they must switch to `AnimaV1.begin(...)` on upgrade. Internally, renaming touches more than the one declaration: a repo scan found the bare `Anima` identifier used in 18 files — 1 addon file (`addons/anima/core/declaration/anima_declaration_node.gd`), 4 existing legacy GUT tests (`tests/Anima.integration*.test.gd`, `tests/test.gd`), and 13 demo scripts/scenes under `demos/`. All of them need the same `Anima` → `AnimaV1` update as part of whichever story does this rename, or the legacy addon breaks internally, not just externally. The same non-colliding-name constraint will recur for `Anima.of(...)` (Node proxy API) whenever that backlog item is scoped into a future phase — no action needed now, just carries forward.
