# Phase Brief — Anima — Phase 7

## Why This Phase

Anima needs a concise code-facing way to author ordinary property motion without making the underlying motion model a second-class concern. Grid choreography extends that approachable layer to a useful visual pattern developers can see and trust.

## Vision

A developer can point at a node, describe its motion in a readable line, compose it with other motion, and inspect the same result in the Composer. For a grid, they can choose where a wave begins and how it travels across the tiles.

## Design Principle

Convenience syntax must always produce the same inspectable, playable motion as the canonical model.

## Core Product Principles

- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.
- Motion should stay comprehensible: the editor should always be able to show execution order, parallel groups, derived duration, and the critical path — never just a black-box result.
- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, seeking, removed targets, layout changes, skipped/reduced motion, property conflicts, and editor preview must all be defined, not left as edge cases.

## Phase Goal

Developers can author, inspect, compile, reverse, validate, and demonstrate target-bound and grid-based Anima 2 motions through one shared motion model.

## Phase Scope

- Deliver the v2-only `Anima.on()` convenience layer for common target properties, explicit composition, modifiers, validation, saved-motion safety, and group-item authoring.
- Keep convenience-created motions equivalent to canonical motions across Composer editing, native compilation, reversal, interruption, performance checks, and automated coverage.
- Add Grid motion with a point of origin, `FROM_TOP` default direction, and Euclidean, Manhattan, Chebyshev, Row, Column, Diagonal, Anti-diagonal, Clockwise, Anticlockwise, spiral inward/outward, and serpentine row/column propagation.
- Provide v2 getting-started and equivalence documentation, plus runnable playground showcases for the convenience API and a 5×5 Card grid. The Grid showcase uses `v2_stuff/ex2.jpg` only as a visual reference.

## Not This Phase

- Anima V1 compatibility aliases or migration shims.
- Additional Grid formula families beyond the selected set.
- Retrofitting every existing playground to `ExamplePlayground`.
- Broader Motion Composer layout, timeline, preview, and inspector work beyond correctly presenting convenience-created motions.

## Exit Criteria

1. Target-bound authoring
   - Developer creates and composes common property motions through `Anima.on()`: the resulting motion plays, validates, reverses, and retains its behaviour when saved.
2. Composer and native parity
   - Developer opens a convenience-created motion in the Composer: its target, semantic property, and canonical representation are visible and editable.
   - Developer compiles or interrupts the motion: its result matches an equivalent canonical property motion.
3. Grid choreography
   - Developer creates a Grid motion from a chosen point: tiles propagate using each selected formula, including clockwise/anticlockwise from 12 o’clock and spiral or serpentine traversal.
4. Showcase and documentation
   - Developer opens the runnable examples: the target-bound and 5×5 Grid Card demonstrations make the new behaviour clear.
   - Developer follows the v2 documentation: the convenience API and its canonical equivalent are both explained.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| Grid motion defaults to `FROM_TOP`; clockwise and anticlockwise start at 12 o’clock and use the chosen point as their centre. | Existing expectations may require a different default or angular origin. |
| The selected Grid formulas are sufficient for the first Grid motion release. | Further traversal types could require a change to the public Grid authoring surface. |

## Acknowledged Risks

- The convenience API covers many related behaviours, so canonical equivalence must remain explicit rather than assumed.
- Grid propagation can become visually ambiguous unless each mode is distinctly demonstrated.
