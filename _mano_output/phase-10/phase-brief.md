# Phase Brief — Anima — Phase 10

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 7 shipped a baseline `Anima.on()` / `Anima.item()` convenience facade, with reversal confirmed working at the time via dedicated parity tests. Several of its documented modifiers (lifecycle callbacks, repeat, duration inheritance, starting-value semantics, relative destination methods) were never formalized, and reverse playback is now missing or broken again — this phase treats that as a regression or an uncovered case (e.g. group/grid) rather than building the facade from scratch.

## Design Principle

Convenience never forks the engine: every `Anima.on()` call must produce output equivalent to the underlying `Motion.animate()` call, and reverse must work uniformly across every motion kind this phase touches.

## Core Product Principles

- Composition over inheritance: Anima attaches to ordinary Godot nodes. Users should never need AnimatedButton, AnimatedPanel, AnimatedContainer, or AnimatedLabel subclasses.
- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, and reduced motion must all be defined, not left as edge cases.

## Phase Goal

A developer can write `Anima.on(node)` to animate a property with lifecycle callbacks, repeat, and playback-direction control — and reverse playback works correctly across every motion kind currently buildable in Anima 2.

## Phase Scope

- Fix the backward-playback regression/gap so it works correctly across single node, sequence, parallel, group, and grid motions (reversal for the facade was confirmed working by Phase 7's own parity tests).
- Harden the existing `Anima.on(target)` facade's factory guarantees — safe reuse for multiple independent motions against the same target, and no call mutating a motion an earlier call already returned.
- Verify and maintain the existing equivalence guarantee: every convenience call still produces a result equivalent to the matching universal `Motion.animate()` call.
- Extend the existing convenience-method calling convention (destination + optional duration positional, everything else a named fluent modifier) with the still-missing modifiers below.
- Lifecycle callbacks on the convenience chain: `on_started` and `on_completed`.
- Duration resolution falls back through a chain when omitted: motion-specific override, then node-behaviour default, then motion-theme default, then the global Anima default.
- Starting value defaults to the property's value at the moment that specific motion begins; an explicit `.from(value)` overrides it.
- Relative destination convenience methods (`move_by()`, `rotate_by()`, a generic `property_by()`) compute their destination from the value captured when the motion begins.
- `repeat` (the v2 term, replacing v1's `loop`) as a composable modifier: count, direction mode, delay, and speed — not one method per combination.
- Playback direction/speed/delay convenience covering forward, backward, and delayed/sped-up start — including selecting direction from a condition at play time (v1's `play_as_backwards_when`).
- Documented, tested handling for GDScript's lack of type-safe method overloads on convenience methods that must accept more than one node/value type.

## Not This Phase

- KeyFrames as a motion type, and keyframe reversal specifically (tracked separately; keyframes aren't built yet).
- The full built-in animation preset catalog (fade/bounce/zoom/etc. — 89 v1 presets) and the preset browser.
- A `Anima.Node()` compatibility alias or any other migration code path — see Stated Technical Preferences.
- A written v1→v2 migration guide (documentation) — deferred to later, once the wider v2 API has landed.
- Easing Demo — scope not yet decided.
- Group item context for dynamic per-item convenience destinations (e.g. lerp by index) — architecture must not block it later, but it isn't required now.
- Re-verifying or re-testing convenience-API behaviour Phase 7's parity tests already covered and that isn't implicated in the reverse regression.

## Exit Criteria

1. Single-node animation
   - `Anima.on($Panel).move_by(Vector2(100, 0)).on_started(...).on_completed(...).play()`: motion runs, both callbacks fire exactly once each, in order.
2. Repeat and direction
   - Same call with `.repeat(3)`: motion plays three times without drift or duplicated callbacks.
   - `.play_backwards()` and a condition-driven backward selection both run the motion in reverse from the correct starting state.
3. Reverse across motion kinds
   - A sequence, a parallel group, a group motion, and a grid motion each reverse correctly when played backwards — visual and logical end state matches playing that same reversed motion forward from its natural start.
4. Equivalence
   - The same effect written with `Anima.on()` and with `Motion.animate()` directly produces the same resource shape and playback behaviour.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The reverse-playback fix in this phase only needs to cover motion kinds already buildable today (single node, sequence, parallel, group, grid); keyframe reverse is a separate, later slice once KeyFrames exist. | If keyframes turn out to share the same reversal machinery, splitting the fix could mean revisiting this phase's reverse work when KeyFrames ship, instead of it just extending cleanly. |
| The built-in animation presets (Phase 12 candidate) will be authored as convenience calls through `Anima.on()` rather than a separate mechanism, so this phase's facade is assumed to be their extension point. | If presets end up needing a different invocation path, this phase's API surface may need rework once that phase starts. |
| `Anima.on()`/`Anima.item()` shipped a working baseline in Phase 7 (reversal confirmed via parity tests); this phase hardens and closes gaps rather than building the facade from scratch, and the reverse-playback issue is a regression or an untested case (e.g. group/grid) rather than something never built. | If the reverse issue is a deeper architectural gap rather than a regression, or more of the "missing" modifiers already exist than assumed, stories could duplicate Phase 7 work or scope the wrong fix. |

## Acknowledged Risks

- Reverse playback across five different motion kinds in one phase is a wide surface; a fix that works for simple cases may not generalise cleanly to nested groups or grids.
- GDScript's lack of overloads means some convenience methods take `Variant`; without careful validation and docs this can produce confusing runtime errors instead of compile-time ones.
- The reverse-playback issue may be a regression introduced in Phase 8 or 9 rather than a gap in Phase 7's original facade — root-causing it (regression vs. never-covered case) is implementation work this brief doesn't resolve.

## Stated Technical Preferences

<!-- Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override. -->

- "use these names" — confirming the lifecycle callback modifiers are named `on_started` and `on_completed`.
- "to keep code clean I won't adding any migration API, but a migration guide at the very end"
