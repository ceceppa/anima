# Phase Brief — Anima — Phase 23

**Track:** v2

## Why This Phase

A fresh audit of the v1 addon found that v2 has no equivalent for two behaviors v1's ported preset catalog (`fade_in`, `zoom_in`, `slide_in_*`, `*_entrances`) depends on: showing a hidden target before an entrance plays, and controlling when a motion's starting values take effect. Without them, those presets behave differently in v2 than they did in v1.

## Design Principle

Match v1's behavior exactly rather than inventing a simplified default, so the ported preset catalog behaves the way users already expect.

## Core Product Principles

- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, seeking, removed targets, layout changes, skipped/reduced motion, property conflicts, and editor preview must all be defined, not left as edge cases.

## Phase Goal

Entrance and exit motions handle a hidden or transparent target correctly, and a motion's starting values can be applied either immediately or only when playback begins — matching v1.

## Phase Scope

1. **Visibility strategy**
   a. **Per-motion strategy** — a motion can specify how it treats a target that starts hidden or fully transparent before it plays: leave it alone, unhide it, make it opaque, or both
   b. **Entrance and exit presets apply it** — the ported entrance/exit presets use this strategy without any extra setup, and an exit motion can leave its target hidden afterward
2. **Starting-value timing**
   a. **Per-motion timing choice** — a motion can specify whether its starting values are written to the target immediately when the motion is set up, or only once playback begins
3. **Playground coverage**
   a. **Visible scenario** — the existing playground shows both the visibility-strategy choices and the starting-value timing choices in action, so they can be verified without reading code

## Not This Phase

- The other v1-parity items still in the backlog (shader parameter animation, decimal-rounded property interpolation, 3D rotation convenience) — unrelated capabilities, left for a later phase
- Changing `reverse` / adding a `play_backwards`-style API — a separate open discussion, not part of this phase
- New entrance/exit presets beyond the existing catalog
- Documentation or a migration guide covering this behavior

## Exit Criteria

1. **Hidden and transparent targets**
   a. Play an entrance motion on a node that starts hidden, with the strategy set to unhide it: the node becomes visible before the motion plays and the motion completes normally
   b. Play an entrance motion on a node that starts fully transparent, with the strategy set to make it opaque: the node becomes visible before the motion plays
   c. Play an entrance motion on a hidden node with the strategy set to leave it alone: the node stays hidden and nothing visible happens
   d. Play an exit motion configured to hide its target afterward: once playback finishes, the node is hidden
2. **Starting-value timing**
   a. Set a motion to apply its starting values immediately: the target shows those values as soon as the motion is set up, with no flash of its previous appearance when playback later begins
   b. Set a motion to apply its starting values only on play: the target keeps its current appearance until playback begins, then jumps to the starting values
3. **Playground coverage**
   a. Open the playground and run the updated entrance/exit scenario: both the visibility-strategy and starting-value-timing choices are visible and testable without reading code

## Validation Plan

### Questions

- **Q1.** Do the four visibility-strategy choices (leave alone / unhide / make opaque / both) cover every entrance and exit case the ported v1 presets need, with nothing left ambiguous?
- **Q2.** Does the immediate-vs-on-play timing choice fully eliminate the visible flash, or does a third timing option turn out to be needed?

### Try

- Run the playground's updated entrance/exit scenario and try each visibility-strategy choice on a hidden node and a transparent node.
- Run the playground's starting-value timing scenario in both modes and watch for a flash of the previous state when playback begins.

## Assumption Log

| ID | Assumption | Risk if wrong |
|---|---|---|
| A1 | The existing entrance/exit presets are the only playback path that needs visibility-strategy and timing handling this phase — group motions and layout-triggered motions aren't in scope here. | A hidden-target or flash bug could still show up through a group or layout-triggered motion, needing another pass later. |

## Acknowledged Risks

- Mirroring v1's two independent configuration choices (rather than a simplified fixed default) adds new public API surface that a future migration guide will need to cover.
- Visibility and timing handling interacts with the interruption behavior (replace, retarget, queue, reverse) shipped in Phase 22; those combinations aren't re-verified here.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
