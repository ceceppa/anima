# Phase Brief — Anima — Phase 6

## Why This Phase

Anima needs a complete, first-class way to distribute one motion across a collection of nodes. This phase makes group animation a production-ready capability rather than a small convenience layer.

## Design Principle

Group animation should express a relationship across targets while keeping ordering, timing, lifecycle, and individual playback observable.

## Core Product Principles

- Relationships before timestamps: users describe "after this," "with this," "wait for this signal" — Anima calculates absolute schedules; the user never repairs timestamps by hand.
- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.

## Phase Goal

Authors can create, inspect, play, reverse, validate, compile, and demonstrate complete Anima 2 group motions across resolved target collections.

## Phase Scope

- Deliver AnimaGroupMotion, its target collections, target resolution, filters, per-item context, and independent item playback.
- Support sequential, parallel, fixed-interval and total-duration staggered playback, completion policies, duration differences, pause, cancellation, speed changes, and lifecycle handling.
- Support forward, reverse, centred, edge, odd/even, seeded-random, grid, and index-origin ordering, including equal-rank waves and reverse distribution.
- Provide Anima 2 equivalents of the former group animation types without retaining the legacy API.
- Provide a complete group code API, reversal record, validation, duplicate-target policy, performance benchmarks, and native Animation support and compilation.
- Deliver Motion Composer group authoring, inspection, target/rank preview, generated timeline, and playback controls.
- Deliver unit and integration coverage plus interactive showcase scenes, including a card-reveal example with all group playback and ordering modes.
- Respect reduced-motion group behaviour.

## Not This Phase

- Legacy group migration or any dictionary-based compatibility API.
- A separate resource for assigning different item motions to different targets.
- Layout-transition-specific reduced-motion behaviour.

## Exit Criteria

1. Authoring and inspection
   - Author defines a group from supported collections, configures playback, ordering, filtering, and lifecycle policies: the same resource is visible and editable in code and the Motion Composer.
2. Playback and resilience
   - Author plays, pauses, changes speed, cancels, and reverses a group: item playbacks, order, waves, and completion remain consistent when targets vary in duration or leave the scene.
3. Native and editor workflow
   - Author previews, validates, and compiles an eligible group: the editor shows resolved targets, generated timing, and any blocker.
4. Showcase
   - Open the group showcases: interactive scenes demonstrate directional, centred, index-origin, odd/even, random, grid, sequential, parallel, staggered, forward, and reverse behaviour.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| Core groups apply one shared item motion to every resolved target. | Heterogeneous target-to-motion mapping would require a separate model and must not be smuggled into this resource. |

## Acknowledged Risks

- The default group-stagger origin remains an unresolved specification decision.
- The complete editor, runtime, and compiler contract is substantial and needs a coordinated technical specification before stories are written.
