# Phase Brief — Anima — Phase 3

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 1 proved the core relational runtime with just Sequence and Parallel. This phase completes the full set of composite motion types the runtime was designed to support polymorphically, plus the ergonomic builder syntax that's the product's own flagship example.

## Vision

A developer describes a staggered list of buttons, a repeating pulse, a race between two competing effects, or a branch that picks one motion over another — using the same fluent `Motion.sequence(...)`-style syntax already promised — and it all composes and plays correctly, with a runnable example scene to watch it happen.

## Design Principle

Every new composite type follows the same polymorphic `create_runtime()`/`advance()` contract Sequence and Parallel already proved, rather than inventing a special case per type.

## Core Product Principles

- Relationships before timestamps: users describe "after this," "with this," "wait for this signal" — Anima calculates absolute schedules; the user never repairs timestamps by hand.

## Phase Goal

Every composite motion type (Sequence, Parallel, Stagger, Repeat, Race, Conditional) composes correctly through the same runtime, motions can be built with relative timing modifiers and a fluent builder syntax, and an example scene demonstrates it all running.

## Phase Scope

- Stagger composition (`AnimaStagger`): a template motion repeated across a target selector with an interval and an ordering (forward, reverse, from-center, from-edges, random, custom).
- Repeat composition (`AnimaRepeat`): a child motion repeated a finite number of times, with a delay between repeats and an alternate (ping-pong) mode.
- Race composition (`AnimaRace`): children run concurrently; the group completes on the first child to finish, optionally cancelling the rest.
- Conditional branch (`AnimaConditional`): selects between two child motions based on a condition, resolved at compile time or at runtime.
- Relationship timing modifiers: start offset, overlap-previous, and start-after-previous-begins, for relative timing between children beyond strict Sequence/Parallel; completion threshold is exact-end only.
- Duration model: every motion reports a duration *kind* — Fixed, Estimated, Dynamic, or Infinite — not just a number.
- Functional builder API: a fluent, chainable GDScript syntax (`Motion.sequence(...)`, `Motion.parallel(...)`, etc.) as an alternative to direct resource construction.
- A basic example scene demonstrating this phase's composition types, runnable and watchable in the Godot editor.

## Not This Phase

- No editor visual distinction for duration kinds — that needs the Motion Composer, which doesn't exist yet (tracked separately in the backlog).
- No spring-settled, visually-settled, named-marker, or signal completion thresholds — each needs a feature not built yet (spring easing, markers, the signal-wait leaf) (tracked separately in the backlog).
- No infinite repeat counts — Repeat is scoped to finite counts this phase.
- No interruption policies or per-property ownership tracking — still deferred, same as Phase 1.
- No node-lifecycle authoring surface (`Anima.of()`'s `enter()`/`exit()` methods) — depends on `AnimaBehaviour`, not built yet.
- No new leaf motion types, layout transitions, shared elements, or native-Animation integration.

## Exit Criteria

1. New composite types
   - A Stagger of several motions on different targets: each starts its own interval apart, in the configured order
   - A Repeat of a motion: it repeats the configured number of times, honouring delay-between and alternate mode
   - A Race of several motions: the group completes as soon as the fastest one finishes; the others stop advancing
   - A Conditional built with a compile-time-known condition: it runs the correct branch
   - A Conditional built with a runtime-only condition: it reports a Dynamic duration until the condition resolves, then runs the correct branch
2. Timing and duration
   - A Sequence child configured to overlap or start-offset against its predecessor: it starts at the shifted time, not strictly after
   - Querying any motion's duration: it reports the correct kind (Fixed, Estimated, Dynamic, or Infinite)
3. Builder syntax
   - The same structures from Exit Criterion 1, built with the fluent builder instead of direct resource construction: identical behaviour
4. Example scene
   - Opening the example scene and running it: the composition types from this phase visibly animate in the Godot editor

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| A Conditional with a runtime-only condition can report Dynamic duration using only the sliced, editor-free Duration model from this phase. | If Dynamic-duration reporting turns out to need more than the runtime concept, Conditional's runtime-resolved case may need rework once the Motion Composer exists. |

## Acknowledged Risks

- Race's "cancel the remaining children" behaviour and Phase 1's existing playback cancellation semantics need to agree on what "cancelled" means for a child that was never given its own top-level playback — this phase should settle that consistently, not leave it ambiguous.
- Repeat's alternate (ping-pong) mode needs a clear reversal rule for a single property motion; getting this wrong would look visually broken even if the loop count is correct.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
