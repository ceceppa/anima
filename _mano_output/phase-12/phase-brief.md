# Phase Brief — Anima — Phase 12

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Anima has no way to author a CSS-style keyframe motion — every leaf motion is still a single from/to property change. Keyframes are one of the most commonly expected animation primitives and PRD5's own delivery roadmap sequences them first among the remaining runtime work.

## Vision

Right now, animating something through several stops — fade in, hold, then slide, for example — means hand-composing a Sequence of separate property motions. This phase lets a developer describe that whole shape in one place, the way CSS `@keyframes` does, in either a plain dictionary or a fluent builder, and have it play, reverse, and demo exactly like every other Anima motion.

## Design Principle

Two authoring surfaces (dictionary, fluent builder) must produce the exact same resource — never let one become a second, subtly different format.

## Core Product Principles

- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same `AnimaMotion` resource — no separate visual-only format.
- Production-ready by default: reversal is part of the definition of "done," not a follow-up.

## Phase Goal

A developer can author a multi-property keyframe motion through either the dictionary or fluent form, see it play and reverse correctly, and see both a keyframe and a spring motion actually running in the playground.

## Phase Scope

- `AnimaKeyframeMotion`: a first-class motion describing one or more properties at normalised offsets across a duration
- Keyframe declarations grouped across multiple offsets at once (e.g. the same block applying at both `"from"` and `10`)
- Offset parsing: flattening, validation, normalisation to 0.0-1.0, sorting, and duplicate-declaration detection — independent of input declaration order
- Multi-property keyframes, with convenience semantic names (`opacity`, `position`, `scale`, `rotation`, `color`, `size`) resolving to their canonical properties, alongside arbitrary property paths
- A fluent construction form (`Motion.keyframes()...`) that produces the identical resource a dictionary declaration would
- Per-segment easing via a reserved, namespaced key, stored separately from animated properties
- Automatic reversal for keyframes with literal (fixed) values
- A "Keyframes" family added to the convenience motion playground, so authored keyframe motions are visually demoable
- A spring-motion demo added to the playground, closing the gap Phase 11's review flagged (spring speed scaling shipped with test coverage only, never a visual one)

## Not This Phase

- Dynamic (non-literal) keyframe values, and reusing a resolved dynamic value on reversal — both depend on `AnimaValue`, which doesn't exist yet
- Motion Composer keyframe editing — depends on the Motion Composer, not built
- Compiling keyframe motions to native `Animation` tracks — a separate, not-yet-scoped compiler item
- Whether `reverse()` should also cover "play this motion backward on demand" (v1's `play_backwards` use case) — flagged by the user as a design question needing its own discussion, not decided here
- A playground demo-selector reorganisation (2D/3D tabs) — unrelated to this phase's outcome

## Exit Criteria

1. Authoring a keyframe motion
   - Call `Anima.on(card).keyframes({"from": {...}, 50: {...}, "to": {...}}).duration(...)`: the card animates through each declared stop in order
   - Build the same motion via `Motion.keyframes().at(...).at(...).duration(...)`: it plays identically to the dictionary form
   - Declare a block at grouped offsets (e.g. `["from", 10]`): both offsets receive the same values
   - Declare multiple properties in one keyframe block, mixing a semantic name (`opacity`) and a raw property path: both animate together correctly
2. Reversal
   - Call `reverse()` mid-flight on a literal-valued keyframe motion: offsets and per-segment easing mirror correctly, playback proceeds backward from its current progress
3. Playground demo
   - Open the convenience motion playground, select the new Keyframes family: the card visibly animates through the authored stops
   - Open the spring motion's playground surface, change its speed: the spring visibly settles faster or slower, matching Phase 11's speed-scaling fix

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| This phase's keyframe values are deliberately literal/fixed only; the deferred `AnimaValue`/"Dynamic values inside keyframes" work will extend (not replace) this model once built | If dynamic-value support needs a different internal keyframe-track representation, this phase's model could need rework rather than a clean extension |
| The convenience motion playground (used for every other leaf-motion family so far) is the right place to add both the Keyframes and spring demos | If either demo doesn't fit that playground's existing UI pattern, a different or new scene may be needed |

## Acknowledged Risks

- Offset parsing (flattening grouped offsets, normalising, sorting, detecting duplicates) is exactly the kind of logic that looks simple and hides edge cases — unsorted input, overlapping groups, and duplicate declarations at the same offset all need explicit, tested behaviour, not just the happy path
- Two authoring surfaces producing the same resource is only verified if something actually asserts equivalence between them, not just that each independently "looks right"

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
