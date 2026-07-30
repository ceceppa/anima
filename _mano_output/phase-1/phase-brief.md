# Phase Brief — Anima — Phase 1

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Anima's value proposition is relational composition — "after this," "with this" — instead of hand-tuned timestamps. Before any editor tooling, layout transitions, or compiler work can be justified, that core runtime needs to exist and be provably correct from code alone.

## Vision

A Godot developer writes a few lines of GDScript describing one animation that runs after another, and a third that runs alongside both — no manual duration math, no wiring up Tweens by hand. They call play() once and watch it run in exactly that relational order, with real easing instead of flat linear motion.

## Core Product Principles

- Relationships before timestamps: users describe "after this," "with this" — Anima calculates absolute schedules; the user never repairs timestamps by hand.
- Composition over inheritance: Anima attaches to ordinary Godot nodes. Users should never need AnimatedButton/AnimatedPanel/AnimatedContainer/AnimatedLabel subclasses.

## Phase Goal

From GDScript, compose Sequence and Parallel motions out of Property-motion leaves with real easing, and play them on ordinary nodes with pause/resume/cancel — no editor UI required.

## Phase Scope

- Compose a motion from nested Sequence and Parallel groups built out of Property-motion leaves.
- Motions use real easing curves (a basic set), not just linear interpolation.
- Motions are constructed directly in code as typed resources — no visual/Inspector authoring yet.
- Playing a motion on a node returns something the caller can await for completion, and can be paused, resumed, or cancelled.
- No project setup (autoload, scene wiring) is required before a motion can be played.

## Not This Phase

- No Inspector section, no Motion Composer, no visual/no-code authoring — code-only in Phase 1.
- No Stagger, Repeat, Race, or Conditional composition — only Sequence and Parallel.
- No leaf types beyond Property motion — keyframe, native-Animation reference, signal wait, delay, callback, audio, shader-parameter, layout, shared-element, and nested-motion-reference leaves are deferred.
- No easing beyond the basic curve set — spring, decay, cubic Bézier, curve resource, callable evaluator, and custom sampled curve easing are deferred.
- No layout transitions or shared-element transitions.
- No native-Animation compiler, import, or reference leaf.
- No fluent/chainable builder syntax — only direct resource construction.
- No behaviour resources, node-attached lifecycle, or state bindings.
- No per-property ownership/conflict detection, and no interruption policy for replacing an in-flight motion on the same target.
- No physics- or manual-clock mode selection — whatever the default evaluation loop uses is Phase 1's only mode.

## Exit Criteria

1. Compose and play
   - Sequence containing a Parallel of two Property motions, followed by a third Property motion: the parallel pair runs simultaneously, then the third motion starts only once both finish
2. Easing
   - Same motion built with two different easing curves: visibly different motion (eased vs. linear)
3. Playback control
   - Pause mid-playback: animated values freeze in place
   - Resume after pause: motion continues from where it paused
   - Cancel mid-playback: motion stops and completion is not reported as success
4. Zero setup
   - Fresh scene, no autoload configured, no prior setup call: playing a motion still works on the first call

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| Phase 1's duration reporting is a single number; the deferred Duration model (Fixed/Estimated/Dynamic/Infinite) later generalises this to a duration *kind*. | Once Dynamic/Infinite leaves (springs, signal waits) ship, every motion type's duration contract may need reworking rather than extending. |
| Phase 1's evaluation loop runs on one implicit tick source; the deferred Clock modes item later makes this configurable (Idle/Physics/Manual). | If the loop hardcodes assumptions about its tick source, adding Physics/Manual modes later could force restructuring instead of extending. |

## Acknowledged Risks

- Concurrent motions can write to the same node property with no conflict detection (ownership tracking is deferred) — a carelessly built Sequence/Parallel could silently fight over a property.
- Playing a new motion on a node that already has one running has no defined behaviour yet (interruption policies are deferred).
- Only a basic easing set ships; developers wanting spring/bounce/elastic feel have nothing to reach for until a later phase.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
