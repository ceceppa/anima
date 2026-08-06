# Phase Brief — Anima — Phase 14

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 13's showcase exposed two real gaps in Anima's motion system — keyframes can't reference a target's own current/computed state, and grid motions have no one-line entry point — both already backlogged and now the only thing blocking that showcase's completion.

## Design Principle

Every dynamic-value capability ships to at least Anima v1's own expressiveness, through the typed v2 API — not a narrower v2-only subset that happens to unblock one showcase.

## Core Product Principles

- Static motion compiles, dynamic motion stays dynamic: anything reducible to a native Animation should compile to one; anything needing runtime state stays Anima-native.
- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.

## Phase Goal

A developer can write a dynamic value that resolves against a target's own live state — standalone, inside a keyframe, or combined with another dynamic value — and start a grid motion in one line via `Anima.grid()`, matching Anima v1's dynamic-value expressiveness through the new typed API.

## Phase Scope

- A dynamic value that resolves against a target's own current property state at motion start, usable anywhere a fixed value is accepted today
- Reading a dynamic value from the animated target itself, from another named node, or from the animation's root/context — matching v1's node/property/sub-property reference reach
- Combining dynamic values arithmetically — against a literal, against another dynamic value, or via arbitrary custom computation — matching v1's ability to combine multiple independent references in one expression
- Dynamic values usable inside keyframe properties, resolved per keyframe the same way they resolve elsewhere
- In a group or grid animation, each item resolves its own dynamic values independently against its own target
- A one-line grid-motion entry point mirroring the existing single-node convenience API's ergonomics
- A demo in the existing convenience-motion playground covering dynamic values (standalone, inside a keyframe, and two combined) and the `Anima.grid()` shorthand, matching how every earlier leaf-motion capability got its own demo family there
- Phase 13's RPG showcase scene completed: its icon-pulse animation uses each icon's own real scale instead of the current shared-literal-scale workaround

## Not This Phase

- Configurable resolution timing (resolving at parent-playback-start, or continuously every frame) — this phase resolves at motion start only, matching v1's own behaviour
- Reversal correctly reusing a previously-resolved dynamic value instead of recomputing it — a separate, already-backlogged item
- Preserving v1's exact string-expression syntax for backward compatibility — the project's already-decided v1→v2 migration path is documentation only, not a code compatibility layer
- Motion Composer (editor) visualisation of dynamic values inside keyframes — separate, already-backlogged editor tooling
- Any RPG-showcase change beyond the icon-pulse fix — scope is limited to what dynamic values and `Anima.grid()` unblock

## Exit Criteria

1. Dynamic values standalone
   - A motion property set to a dynamic value referencing the animated target's own property: the motion starts from/goes to the target's actual live value, not a hardcoded number
2. Dynamic values across nodes
   - A motion property set to a dynamic value referencing a different named node's property: it resolves that node's actual value
3. Combined dynamic values
   - A motion property set to two dynamic values combined arithmetically (e.g. one node's value plus another's): the resolved result reflects both
4. Dynamic values inside keyframes
   - A keyframe property set to a dynamic value: each keyframe step resolves it correctly, the same way it resolves outside keyframes
5. Per-item resolution in groups and grids
   - The same dynamic-value motion applied across a group or grid's items: each item resolves the value against its own target, never a shared value
6. Anima.grid() shorthand
   - A grid motion started with a single `Anima.grid(container)` call: it runs equivalently to the existing hand-built target-collection-plus-grid-motion approach
7. Playground demo
   - Opening the convenience-motion playground: a Dynamic Values family demonstrates a standalone dynamic value, one inside a keyframe, and two combined; `Anima.grid()` runs from the same playground
8. Showcase completion
   - Opening the Phase 13 showcase scene and pressing play: the icon-pulse animation in Scene 1 now scales each icon relative to its own real fitted size, not one shared literal value

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| This phase's dynamic values resolve once, implicitly, at motion start — the deferred configurable resolution-timing item later adds parent-playback-start and continuous resolution as additional modes, not a replacement for this default. | If a different default resolution point turns out to be needed for common cases, later configurability might require revisiting how this phase resolves values rather than cleanly adding options on top. |
| Combining dynamic values arithmetically (this phase) is a distinct concern from correctly reusing a resolved value on reversal (deferred) — this phase does not guarantee a reversed motion re-uses its originally resolved dynamic value instead of recomputing it. | A motion using dynamic values could visibly reverse "wrong" (recomputed against a since-changed target) until the deferred reversal-reuse item ships. |

## Acknowledged Risks

- Anima v1's actual dynamic-value implementation (its docs and parsing logic) is richer than any single backlog item's own short summary — the technical design should be checked directly against that source material, not just the item text, before the contract is finalised
- Exactly what a "root" or "context" reference means for a dynamic value, and whether it matches v1's own root-node/current-node distinction, is not decided by this brief

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
