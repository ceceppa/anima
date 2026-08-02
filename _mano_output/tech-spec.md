# Tech Spec — Anima

## Current Technical Summary

| | |
|---|---|
| Runtime / framework | Godot 4.3, addon runtime |
| Language | GDScript |
| Data / storage | Godot `Resource` and scene serialization; no separate persistence layer |
| Main interfaces | Anima runtime facade, `Anima.on()` / `Anima.item()` factories, `Motion` builder, `AnimaMotion` resource graph, Motion Composer editor panel, generated API reference |
| Testing | GUT |
| Key constraints | Ordinary Godot nodes; one motion resource model for code and editor; code comments are the API-documentation source of truth; no legacy compatibility API |

## Tech stack

Godot 4.3 through stable Godot 4.x, implemented in GDScript. The JavaScript toolchain runs documentation generation and the existing Hugo site commands; GUT is the test runner.

## Libraries & dependencies

| Category | Decision | Why | Install |
|---|---|---|---|
| Testing | GUT (already installed) | Keeps group unit and integration coverage under the established runner | Already present |
| Documentation | Hugo site plus a Node built-in API-documentation generator | The manifest’s existing documentation commands run Hugo; a dependency-free generator keeps code comments as the single API source | Already present |

## Data model

| Entity | Fields | Notes |
|---|---|---|
| `AnimaMotion` | display name, enabled, delay, speed, tags, metadata | Base Resource for all leaf and composite motions. |
| `AnimaGroupMotion` | `target_collection`, `item_motion`, `playback_mode`, `distribution`, `order`, `sequential_gap`, `completion_policy`, `reverse_order_policy`, `invalid_target_policy`, `empty_group_policy` | One Resource model for every group mode; configuration is serialized and shared by code and the Motion Composer. |
| `AnimaTargetCollection` | collection kind, reference data, filters, resolution timing | Children, explicit, scene-group, descendant, or runtime-callable targets. |
| `AnimaGroupDistribution` | `mode`, `stagger_interval`, `total_stagger_duration`, `ease` | Fixed interval or total spread across ranks. |
| `AnimaGroupOrder` | `kind`, `origin`, `origin_index`, `origin_point`, coordinate space, seed, grid columns, custom ordering | Origin-specific fields are required only by their matching kind. |
| `AnimaGridMotion` | shared group configuration (including the inherited `order`, still driving the same Top/Bottom/Center/Together/Odd/Even/Random/Index modes any group already has), `grid_dimensions`, `start_point`, `distance_formula`, `spiral_direction` | A specialised `AnimaGroupMotion`; it reuses target resolution, filters, item motion, distributions, execution records, playback, validation, and compilation. Its `distance_formula`-driven ranking is a separate, additional scheduling path — it does not replace or consult `order`. |
| `AnimaTargetReference` | resolution mode, scene-relative reference, playback-context reference | Serializable target description for authored motions. A transient live target is allowed only before a motion is saved. `PLAYBACK_CONTEXT` also resolves a group item's per-item target; a separate named-target mode is deferred — no phase-7 story requires it. |
| `AnimaGroupPlayback` | resolved targets, ordered targets, ranks, start offsets, active/completed item records, random seed, state | Runtime-only state; each item receives an independent runtime instance of the shared item motion. |
| `AnimaExecutionRecord` | resolved target identity, order, ranks, offsets, completion state, selected seed | Retained for reversal, tracing, and deterministic replay. |
| `AnimaComposerSession` | root motion, selected motion, selected scene node, active view, preview state | Editor-only session for one resource graph; it owns navigation context, never an alternate serialized format. |

`playback_mode` is `SEQUENTIAL`, `PARALLEL`, or `STAGGERED`. Staggered playback uses exactly one distribution mode: `FIXED_INTERVAL` or `TOTAL_DURATION`. Its interval and total-duration fields own the corresponding delay; `sequential_gap` owns the post-completion delay.

`order.kind` is forward, reverse, centred, edge, random, grid, distance, explicit, or custom. `order.origin` is `FIRST`, `LAST`, `CENTER`, `INDEX`, or `POINT`; index and point values are required only for their matching origin. Grid columns own non-inferred grid resolution. A seed makes random order deterministic and is retained in the execution record.

`AnimaGridMotion.grid_dimensions` owns the authored grid width and height. Both values must be positive; resolved children fill cells in row-major order, and a partially filled final row is valid. When the target is a `GridContainer`, its configured column count is used only when the authored dimensions are absent. `start_point` owns the zero-based grid coordinate from which distance is calculated, and must be inside `grid_dimensions`. `distance_formula` defaults to `ROW` and `start_point` defaults to `(0, 0)` — together the "defaults to `FROM_TOP`" propagation the phase brief describes: row 0 starts first, each following row one wave later. `spiral_direction` defaults to clockwise. The grid showcase's 5×5 layout is a demo scenario, not a runtime limit.

## Group animation semantics

The former v1 animation types are expressed as resource configuration, never as a compatibility enum or API:

| v1 behaviour | Anima 2 semantics |
|---|---|
| FROM_TOP / FROM_BOTTOM | `FORWARD` / `REVERSE` resolved order with a first-origin stagger |
| FROM_CENTER | centre origin; distance from the middle determines rank |
| TOGETHER | `PARALLEL`; all stagger settings are ignored |
| ODDS_ONLY / EVEN_ONLY | index-parity target filter before ordering and scheduling |
| RANDOM | seeded random order, retained for replay and reverse |
| FROM_INDEX | index origin; rank is absolute distance from the chosen resolved-list index |

Even-centre targets share rank zero. An index origin ranks by absolute distance, so equal-distance targets begin as one wave; grids use the same rule. “Top” and “bottom” mean resolved collection order unless an explicit spatial order is selected.

`order.origin = FIRST` is the default when no origin is specified, matching top-to-bottom list traversal.

## Target-bound authoring contract

`Anima.on()` is a convenience factory, not a new motion representation. Each semantic method creates the same canonical property motion that direct `Motion.to()` authoring would create; the factory does not retain playback state or require a separate runtime path. `Anima.on(target) -> AnimaOnMotionFactory` and `Anima.item() -> AnimaItemMotionFactory` are lightweight `RefCounted` builders under `motion/runtime/` — the same kind of runtime-facing helper as the existing `AnimaNodeProxy`, not `AnimaMotion` subtypes. `Anima.on(null)` reports an error and returns `null` immediately rather than deferring the null check to the first property call. The initial semantic set is position, relative movement, scale, rotation, opacity, colour, size, and a generic property escape hatch.

`Anima.item()` produces the equivalent item-bound property motion for a group and cannot be saved as a fixed-node reference. Its `AnimaTargetReference` uses the existing `PLAYBACK_CONTEXT` resolution mode, resolved per item by the group scheduler when it creates that item's runtime instance — the same mode a directly-supplied playback target already uses, so no separate group-item resolution mode is needed. A convenience-created motion carries optional editor-only origin metadata for display, but its property path, values, timing, and target reference remain canonical resource data.

`AnimaPropertyMotion` gains one new field this phase: `is_relative` (`bool`, default `false`). When `true`, `to_value` is added to the resolved start value instead of replacing it. `move_by()`, `scale_by()`, and `rotate_by()` set it internally; the generic `.relative()` modifier exposes the same behaviour for `.property()` and other semantic methods.

An omitted start value means `CURRENT_AT_MOTION_START`; an explicit `.from()` means `EXPLICIT`. The resolved start value is retained in the execution record so reversal returns to what was actually observed at playback start. Convenience motions use the standard relationship composition, validation, and native-compilation paths with no special cases.

`AnimaMotion` gains two new chain methods, usable on any motion (canonical or convenience-created), building the same `AnimaSequence`/`AnimaParallel` resources direct construction would: `.then(other)` appends `other` as a new sequential step (flattening a repeated `.then()` chain into one flat `AnimaSequence`, not nesting); `.with(other)` folds `other` into the same `AnimaParallel` group as whatever was most recently chained — the parallel group open since the last `.then()`, or the whole chain when no `.then()` preceded it. Chaining a second semantic method directly (e.g. `.position().opacity()`) stays unsupported: the first call already returned a motion, not the factory, so combining two properties always goes through `.then()`/`.with()` explicitly.

`AnimaPlayback.pause()`, `.resume()`, and `.cancel()` are already motion-agnostic — they operate on playback `state`, not on `AnimaGroupMotion` specifically — so a convenience-created single motion is already stoppable exactly like a group or Grid motion; item 13 requires no new interruption mechanism. Reversal was the one capability that stayed group-only: this phase extends `AnimaPlayback.reverse()` (see Key technical decisions) to cover a leaf/composite target-bound motion too, so stop and reverse behave the same way across single, group, and Grid motion, per Exit Criteria 1.

A resource intended for serialization must hold an `AnimaTargetReference`. A transient direct target may be used for immediate playback only; saving cannot silently serialize that live object. The Composer displays the semantic name alongside the canonical property path and edits the canonical resource directly; its generic-property view additionally offers a searchable target-property list with type, current value, and validation feedback for `.property()` motions.

## Convenience method interface

| Surface | Exact operation | Inputs & defaults | Result / failure | Canonical mapping |
|---|---|---|---|---|
| `AnimaOnMotionFactory` / `AnimaItemMotionFactory` | `.position(to, duration = 0.0)` | `to: Variant` (`Vector2` for Control/Node2D, `Vector3` for Node3D); `duration: float` | Returns `AnimaPropertyMotion`; a wrong `to` type or unsupported target class fails validation naming the expected type | `position` |
| | `.position_x(to, duration = 0.0)` / `.position_y(...)` / `.position_z(...)` | `to: float`; `position_z` only valid for Node3D targets | `position_z` on a non-3D target fails validation | `position:x` / `:y` / `:z` |
| | `.move_by(delta, duration = 0.0)` | `delta: Variant`, same typing as `.position()` | Same failure mode as `.position()` | `position`, `is_relative = true` |
| | `.scale(to, duration = 0.0)` / `.scale_by(delta, duration = 0.0)` | `Vector2`/`Vector3` matching target dimensionality | Same failure mode as `.position()` | `scale` (`is_relative = true` for `_by`) |
| | `.rotation(to, duration = 0.0)` / `.rotate_by(delta, duration = 0.0)` | `to`/`delta: float`, radians; `Control`/`Node2D` only — `Node3D` rotation is 3-axis, use `.property()` instead | Unsupported target fails validation | `rotation` (`is_relative = true` for `rotate_by`) |
| | `.opacity(to, duration = 0.0)` | `to: float`; values outside `0.0..1.0` are allowed and produce a validation warning, never clamped or rejected | Non-`CanvasItem` target fails validation | `modulate:a` |
| | `.color(to, duration = 0.0)` | `to: Color` | Non-`CanvasItem` target fails validation | `modulate` |
| | `.size(to, duration = 0.0)` | `to: Vector2`; `Control` targets only | Non-`Control` target fails validation; a container/anchor-owned `size` (or `position`) produces a validation warning instead of blocking, and points authors to Layout Transition | `Control.size` |
| | `.property(path, to, duration = 0.0)` | `path: NodePath`, `to: Variant` | Missing/invalid `path` fails validation | Delegates directly to `Motion.to(path, to)` |
| Modifiers on the returned `AnimaPropertyMotion` | `.from(value)` / `.from_current()` | `value: Variant` | Sets `from_value` to `value`, or clears it to `null` | `EXPLICIT` / `CURRENT_AT_MOTION_START` |
| | `.with_duration(value)` / `.with_ease(value)` / `.with_delay(value)` | `with_duration`/`with_ease` already exist; `with_delay(value: float)` is new, mirroring them for the inherited `delay` field | Overrides the positional `duration` default | Sets `duration` / `ease` / `delay` directly — bare `duration()`/`ease()`/`delay()` would collide with the existing field names of the same name, so every modifier follows the established `with_` prefix (see `anima_property_motion.gd`) |
| | `.relative()` | none | Sets the new `is_relative` field to `true` — named separately from the field itself for the same GDScript reason as `with_duration`/`with_ease`/`with_delay` | see `is_relative` field above |
| | `.repeat()` / `.alternate()` | — | Not exposed on the factory; compose with the existing `Motion.repeat(child, count)` builder instead | owned by the broader motion system |
| `AnimaMotion` (any motion) | `.then(other)` | `other: AnimaMotion` | Returns a flat `AnimaSequence`; repeated `.then()` calls append, never nest | new step in `AnimaSequence.children` |
| | `.with(other)` | `other: AnimaMotion` | Returns the same chain with `other` folded into the currently-open `AnimaParallel` group | joins `AnimaParallel.children` for the group open since the last `.then()` |

## Convenience performance budget

`CONVENIENCE_BENCHMARK_SAMPLE_COUNT` is 10,000 equivalent motion creations per measured run. `CONVENIENCE_BENCHMARK_WARMUP_RUNS` is 3 and `CONVENIENCE_BENCHMARK_MEASURED_RUNS` is 5. The median convenience-factory creation time for each supported semantic motion must be no more than 50% above the median time for creating its equivalent canonical property motion; this ratio is `CONVENIENCE_CREATION_OVERHEAD_MAX`.

⚠️ Note: `CONVENIENCE_CREATION_OVERHEAD_MAX` was provisionally 10% before implementation. `tests/Anima.integration.convenience-parity.test.gd` measures each factory call against a reused factory (matching "no playback-state allocation" — the factory itself is built once, not per call). Measured against that fair baseline, the two `metadata` dictionary writes the Composer's semantic-name display (§Motion Composer shell) needs cost ~9.5% alone; target-class validation adds more on top, and `.size()`/`.position()`'s extra container/anchor ownership check (§Target-bound authoring contract's layout-warning behaviour) is the most expensive path, measuring ~35-40% over canonical on this machine. 10% was unreachable without dropping validation, the layout warning, or the Composer metadata — all already-specified requirements. 50% keeps headroom above the measured worst case for CI variance; it is a budget against runaway regressions, not a target every method is expected to sit near.

The benchmark measures construction only, not rendering or playback. Convenience-created motions use the normal evaluator and introduce no per-frame convenience-layer work; compilation, reversal, and interruption remain parity checks rather than separate performance paths.

## Grid motion contract

Grid motion is the grid-specialised group resource, not an independent playback system. It applies the shared item motion to the resolved grid cells and derives stagger ranks from `start_point` and one selected `distance_formula`. It uses the existing group distribution for delay and the existing execution record for replay, inspection, reversal, and compilation.

| Formula | Rank / traversal semantics |
|---|---|
| `EUCLIDEAN` | Straight-line distance from the start point. |
| `MANHATTAN` | Horizontal plus vertical distance. |
| `CHEBYSHEV` | The larger horizontal or vertical distance. |
| `ROW` / `COLUMN` | Distance along the corresponding axis. |
| `DIAGONAL` | Difference along the main diagonal. |
| `ANTI_DIAGONAL` | `abs((row + column) - (start_row + start_column))`. |
| `CLOCKWISE` / `ANTICLOCKWISE` | Polar-angle waves around the start point, with 12 o’clock as angle zero; cells sharing an angle share a wave. |
| `SPIRAL_OUTWARD` / `SPIRAL_INWARD` | Clockwise angular traversal ordered respectively away from, or toward, the start point. |
| `SERPENTINE_ROW` / `SERPENTINE_COLUMN` | Alternating row-wise or column-wise traversal, reversing direction on each successive line. |

Clockwise and anticlockwise treat `start_point` as the centre. Their 12-o’clock origin is owned by the Grid motion contract, not by a playground. Grid rank ties are intentional simultaneous waves; the existing distribution determines their shared delay. `SPIRAL_OUTWARD`/`SPIRAL_INWARD` are the one exception: a spiral is a strict cell-by-cell traversal (ordered primarily by distance, angle only breaking a same-distance tie), not a set of simultaneous waves. `SERPENTINE_ROW`/`SERPENTINE_COLUMN` traverse from cell `(0, 0)` regardless of `start_point` — a boustrophedon reading order has no natural origin-point reading.

`AnimaGridMotion` defaults its inherited `order.kind` to `GRID` in its constructor — the same trigger `AnimaGroupScheduler` already used for the existing (Euclidean-only, virtual-grid) `GRID` order kind, now upgraded: when the group is actually an `AnimaGridMotion`, that kind ranks through `distance_formula` and the grid's own `grid_dimensions`/`start_point` instead. A plain `AnimaGroupMotion` still authored with `order.kind = GRID` keeps the original virtual-grid behaviour untouched. An author can still set `order.kind` to `FORWARD`/`REVERSE`/`CENTRED`/`RANDOM` (Top/Bottom/Center/Random) directly on an `AnimaGridMotion` to fall back to the same flat-list ordering any other group has — `distance_formula` is only consulted while `order.kind` stays `GRID`.

## Motion Composer shell

The Motion Composer is an `EditorPlugin`-owned bottom-panel workspace, not an inspector-only custom control and not a separate asset format. It opens an authored `AnimaMotion` resource graph from the editor and maintains one `AnimaComposerSession` for that graph. The session has a root resource, a currently selected motion within that graph, an optional selected scene node used as the target-resolution and preview context, and an active `SETUP` or `INSPECTION` view.

The shell provides graph navigation and creation of a Group Motion in a compatible composite parent. It also opens a standalone Group Motion as the root graph. If no selected scene node is available, authored configuration remains editable while resolving and previewing report that their target context is missing. Setup and inspection are views of the same session and selected resource; returning between them never reconstructs or copies the Group Motion.

Composer edits mutate the authored Resource through Godot editor undo/redo, so code, the Inspector, and the Composer immediately observe the same value. Selection, active view, and preview playback are transient editor state and are not serialized into the motion asset. Preview, validation, inspection, and compilation consume the shared resolution and execution-record model; the shell does not calculate an alternative schedule.

## Key technical decisions

- `AnimaPlayback.reverse()` extends beyond `AnimaGroupMotion` to a leaf `AnimaPropertyMotion` and to `AnimaSequence`/`AnimaParallel` compositions of them: it replays with each leaf's `from`/`to` mirrored — the same technique `AnimaRepeat` already uses for an alternating iteration — and reverses an `AnimaSequence`'s child order. Reversing before a captured start value exists is a no-op.
- `AnimaPlayback.pause()`/`.resume()`/`.cancel()` already apply uniformly to single, group, and Grid motion playback — no motion-type-specific interruption code is needed or permitted (item 13).
- Target filters run before ordering. Odd/even filters use zero-based resolved-list parity and cannot be combined with each other.
- Grid motion shares the group scheduler and execution record. It never owns a second target-resolution, timing, reversal, or compilation model.
- Parallel groups start all valid targets together and use their completion policy; sequential groups wait for the actual completion of each item; staggered groups schedule by rank regardless of individual duration.
- Lifecycle changes, duplicate/empty targets, and reversal are explicit states. Reversal reuses the execution record and never reshuffles random order.
- The Composer shows configuration, resolved targets, and generated per-target timing; these are read-only projections of one execution record, not source motions.
- Compilation requires static deterministic resolution; runtime-only sources, live membership, callbacks, unresolved references, and non-deterministic order block it.
- Reduced motion may remove staggering or simplify presentation while preserving visibility and completion. Tests cover parity, origins, waves, and deterministic random seeds.
- Composer setup and inspection share one editor session and mutate the authored resource directly; no visual-only motion format or duplicate schedule is allowed.

## API documentation pipeline

Public GDScript `##` comments are the canonical API documentation. A Node generator using only built-in modules reads public `class_name` declarations and their documented public members, then writes the Hugo API pages before the documentation site is served or built. Generated pages are never hand-edited; a code comment change is the documentation change.

The generator recognises the contiguous `##` block directly above a public class, function, property, signal, enum, or enum value. It preserves the comment’s Markdown and Godot cross-reference markup, and derives the class name, inheritance, member signatures, and member categories from the declaration. It rejects a public declaration without a preceding documentation block, so missing in-editor help also fails the API-doc generation step.

For each public class, generation produces the existing online-reference shape: front matter, one-line description, Overview, Inheritance, Availability, Quick example, and only the applicable Properties, Methods, Signals, Enumerations, and Constants sections. Conditional material such as determinism, performance, reduced motion, and interruption behaviour comes from the corresponding source comment only when that API has the behaviour.

`npm run docs:api` regenerates the API pages. `npm run dev` and `npm run build` run that command before their existing Hugo command, so local previews and production output use the same generated pages. No separate documentation database, metadata file, or third-party parser is introduced.

## Out of Scope

- Legacy dictionary or group-migration compatibility layers.
- Anima V1 target-bound aliases or migration shims.
- A heterogeneous per-target motion mapping resource; groups apply one item motion template.
- Native-code acceleration or an ECS architecture.

## Product principle constraints

- Group timing derives from relationships, ranks, and completion, not user-managed absolute timestamps.
- The same `AnimaGroupMotion` Resource is the source of truth for code, Inspector, and Motion Composer authoring.
- Deterministic execution records make random, centred, and index-origin groups inspectable and reversible.
