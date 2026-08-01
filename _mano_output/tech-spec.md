# Tech Spec — Anima

## Current Technical Summary

| | |
|---|---|
| Runtime / framework | Godot 4.3, addon runtime |
| Language | GDScript |
| Data / storage | Godot `Resource` and scene serialization; no separate persistence layer |
| Main interfaces | Anima runtime facade, `Motion` builder, `AnimaMotion` resource graph, Motion Composer |
| Testing | GUT |
| Key constraints | Ordinary Godot nodes; one motion resource model for code and editor; no legacy compatibility API |

## Tech stack

Godot 4.3 through stable Godot 4.x, implemented in GDScript. The JavaScript toolchain is documentation-only; GUT is the test runner.

## Libraries & dependencies

| Category | Decision | Why | Install |
|---|---|---|---|
| Testing | GUT (already installed) | Keeps group unit and integration coverage under the established runner | Already present |
| Documentation | VuePress 1.9.10 with its committed plugins | Existing documentation toolchain | Already present |

## Data model

| Entity | Fields | Notes |
|---|---|---|
| `AnimaMotion` | display name, enabled, delay, speed, tags, metadata | Base Resource for all leaf and composite motions. |
| `AnimaGroupMotion` | `target_collection`, `item_motion`, `playback_mode`, `distribution`, `order`, `sequential_gap`, `completion_policy`, `reverse_order_policy`, `invalid_target_policy`, `empty_group_policy` | One Resource model for every group mode; configuration is serialized and shared by code and the Motion Composer. |
| `AnimaTargetCollection` | collection kind, reference data, filters, resolution timing | Children, explicit, scene-group, descendant, or runtime-callable targets. |
| `AnimaGroupDistribution` | `mode`, `stagger_interval`, `total_stagger_duration`, `ease` | Fixed interval or total spread across ranks. |
| `AnimaGroupOrder` | `kind`, `origin`, `origin_index`, `origin_point`, coordinate space, seed, grid columns, custom ordering | Origin-specific fields are required only by their matching kind. |
| `AnimaGroupPlayback` | resolved targets, ordered targets, ranks, start offsets, active/completed item records, random seed, state | Runtime-only state; each item receives an independent runtime instance of the shared item motion. |
| `AnimaExecutionRecord` | resolved target identity, order, ranks, offsets, completion state, selected seed | Retained for reversal, tracing, and deterministic replay. |

`playback_mode` is `SEQUENTIAL`, `PARALLEL`, or `STAGGERED`. Staggered playback uses exactly one distribution mode: `FIXED_INTERVAL` or `TOTAL_DURATION`. Its interval and total-duration fields own the corresponding delay; `sequential_gap` owns the post-completion delay.

`order.kind` is forward, reverse, centred, edge, random, grid, distance, explicit, or custom. `order.origin` is `FIRST`, `LAST`, `CENTER`, `INDEX`, or `POINT`; index and point values are required only for their matching origin. Grid columns own non-inferred grid resolution. A seed makes random order deterministic and is retained in the execution record.

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

## Key technical decisions

- Target filters run before ordering. Odd/even filters use zero-based resolved-list parity and cannot be combined with each other.
- Parallel groups start all valid targets together and use their completion policy; sequential groups wait for the actual completion of each item; staggered groups schedule by rank regardless of individual duration.
- Lifecycle changes, duplicate/empty targets, and reversal are explicit states. Reversal reuses the execution record and never reshuffles random order.
- The Composer shows configuration, resolved targets, ranks, offsets, and critical path; timeline rows are derived, not source motions.
- Compilation requires static deterministic resolution; runtime-only sources, live membership, callbacks, unresolved references, and non-deterministic order block it.
- Reduced motion may remove staggering or simplify presentation while preserving visibility and completion. Tests cover parity, origins, waves, and deterministic random seeds.

## Out of Scope

- Legacy dictionary or group-migration compatibility layers.
- A heterogeneous per-target motion mapping resource; groups apply one item motion template.
- Native-code acceleration or an ECS architecture.

## Product principle constraints

- Group timing derives from relationships, ranks, and completion, not user-managed absolute timestamps.
- The same `AnimaGroupMotion` Resource is the source of truth for code, Inspector, and Motion Composer authoring.
- Deterministic execution records make random, centred, and index-origin groups inspectable and reversible.
