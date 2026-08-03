# Phase Brief — Anima — Phase 9

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 8's entry point fixed the biggest Motion Composer dead end, but the dock still has no hands-on example to learn from, and now that a developer can actually reach it, other dead ends may still surface.

## Design Principle

Every editor panel must always tell the developer what to do next — never leave them looking at an empty view with no path forward.

## Core Product Principles

- Motion should stay comprehensible: the editor should always be able to show execution order, parallel groups, derived duration, and the critical path — never just a black-box result.
- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.

## Phase Goal

A developer can navigate the Motion Composer without hitting an unexplained dead end, and can open a runnable example for each `addons/anima/editor/` tool to learn it hands-on.

## Phase Scope

- Motion Composer usability fixes beyond the entry point: an empty graph names what to add next, and switching between editing a group, editing one of its property motions, and inspecting a resolved run is unambiguous.
- The same usability check — every panel's empty/nothing-actionable state names a concrete next action — verified and fixed where needed across all four editor panels: Motion Composer, Group Composer, Property Motion Composer, Group Inspector.
- Runnable showcase scenes under `examples/editor/` for all four panels, so a developer can select a node and drive each tool live, not only read the written guide.

## Not This Phase

- The fuller PRD Motion Composer vision — toolbar, editable structure tree, Inspector tabs, timeline/curve-preview panels, validation panel — a much larger rebuild, deferred as its own future phase.
- The fuller per-node Anima Inspector behaviour section (Enable toggle, then Lifecycle/Defaults/Layout/States/Shared Element/Accessibility groups) — still deferred; unrelated to this phase's navigation fixes.
- New editor capabilities beyond usability and showcase examples — undo/redo, editor state persistence, a runtime debugger panel, and similar are separate, larger backlog items.

## Exit Criteria

1. Motion Composer navigation
   - Developer opens a group with an empty graph: the empty state names a concrete action to take next
   - Developer switches between editing the group, editing one of its property motions, and inspecting a resolved run: each switch has a clear, discoverable affordance, never a dead click
2. Other editor panels
   - Developer reaches an empty/nothing-actionable state in Group Composer, Property Motion Composer, or Group Inspector: it also names a concrete next action
3. Editor tooling showcase
   - Developer opens the Motion Composer showcase scene under `examples/editor/`: selects a node and drives the dock live
   - Same for the Group Composer, Property Motion Composer, and Group Inspector showcase scenes

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| This phase's Motion Composer usability fixes are minimal navigation/messaging improvements to the existing lightweight dock, not the fuller PRD Motion Composer vision (toolbar, structure tree, timeline panel) already noted in the backlog. | If the fuller Composer rebuild lands first, this phase's specific navigation affordances could be reworked or discarded rather than reused. |

## Acknowledged Risks

- The dock's confusion may run deeper than the two named dead ends (empty graph, unclear switching); a real usability pass across all four panels could surface more once someone is actually driving them for the showcase scenes.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
