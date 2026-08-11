# Phase Brief — Anima — Phase 15

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 14's review surfaced that the `Anima.on`/`Anima.grid` fluent builder has real gaps and at least one broken path (`.with()` chaining) — these block everyday use of the API and should close before anything else builds on top of it.

## Design Principle

Fix and complete the existing builder surface before extending it further — a chain that can't `.play()` or combine reliably isn't ready to carry new capability.

## Phase Goal

A developer can build any `Anima.on`/`Anima.grid` motion — standalone, delayed, eased, or combined with another motion — entirely through the fluent builder API, with every call behaving as documented.

## Phase Scope

- `Anima.on(...)` chains can be started directly with `.play()`
- Combining two motions via `.with(...)` plays and stops correctly
- `Anima.on(...)` supports `with_delay`
- `Anima.on(...)`'s `with_ease` accepts an `AnimaEase.Kind` value directly
- `Anima.grid(...)` exposes `on_started` and `on_completed` callbacks
- `Anima.grid(...)` supports `with_delay`
- Pivot is set via a consistently named `AnimaPivot.Kind` value (replacing the current `AnimaPropertyMotion.Pivot` naming)
- `Anima.on(...)` offers `fade_out` and `fade_in` convenience shorthands

## Not This Phase

- The `animation` keyword/name-based playback on `Anima.on`/`Anima.grid` — a separate, already-backlogged item that extends this same builder once it's reliable
- Porting Anima v1's built-in animation library — its own future phase, not bundled here
- Any other convenience shorthand beyond `fade_in`/`fade_out`

## Exit Criteria

1. Basic playback
   - `Anima.on(node).move_by(...).play()`: motion plays immediately from the chain
2. Chaining
   - Two motions combined via `.with(...)`: both play together and stop/complete correctly
3. Delay and ease
   - `Anima.on(node).move_by(...).with_delay(...).play()`: motion starts after the delay
   - `Anima.on(node).move_by(...).with_ease(AnimaEase.Kind.EXPONENTIAL).play()`: motion eases as specified
4. Grid callbacks and delay
   - `Anima.grid(container).with_delay(...).play()`: grid items start after the delay
   - `on_started`/`on_completed` callbacks fire at the expected points
5. Pivot naming
   - `.with_pivot(AnimaPivot.Kind.CENTER)`: resolves the same pivot the old `AnimaPropertyMotion.Pivot.CENTER` did
6. Fade convenience
   - `Anima.on(node).fade_out(0.3).play()` and `Anima.on(node).fade_in(0.3).play()`: fade the node as expected

## Validation Plan

- **Decision this informs:** Whether the `Anima.on`/`Anima.grid` builder is solid enough to extend next (starting with the animation-keyword item)
- **Evidence to gather:** Exercising each fixed/added method directly in the convenience-motion playground and confirming the observed behaviour matches Exit Criteria

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| This phase fixes and completes the current `Anima.on`/`Anima.grid` builder signatures without adding the deferred `animation` name/tres keyword — that later item must extend this builder's call surface, not rework it. | If the animation-keyword addition needs a different call shape than what this phase locks in, it could force a breaking rework of the builder shortly after this phase ships. |

## Acknowledged Risks

- The `.with()` chaining defect's root cause isn't diagnosed yet (review explicitly didn't investigate) — the fix scope could turn out larger than a single-method patch once implementation starts
