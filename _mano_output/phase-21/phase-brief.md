# Phase 21: Predictable motion conflicts and demo discovery

## Why this phase

When two motions reach for the same property, people need a clear, dependable result instead of a race. The demo selector should also make the Grid Showcase easy to find.

## Design principle

Make motion conflicts explicit, and make the intended result easy to inspect.

## Core Product Principles

- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, seeking, removed targets, layout changes, skipped/reduced motion, property conflicts, and editor preview must all be defined, not left as edge cases.

## Phase Goal

People can start a new motion on an already-animated property and get the policy-selected outcome without competing motion writes.

## Phase Scope

1. **Motion conflict handling**
   a. **Ownership** — each animated property has one active motion owner, so competing motion requests are detected rather than silently applied together
   b. **Interruption choices** — a new motion request follows its selected replace, retarget, reverse, queue, cancel, complete-current, or ignore-new behaviour
   c. **Observable outcome** — completed, cancelled, queued, and redirected motion requests leave the affected property in the policy-selected state
2. **Demo selector**
   a. **Showcase category** — the selector presents a Showcase category containing the Grid Showcase demo

## Not This Phase

- Visual-state, layout-transition, or shared-element-specific interruption behaviour.
- Additional Showcase demos or broader demo-selector redesign.
- A debugger panel or new editor tooling for inspecting motion conflicts.

## Exit Criteria

1. **Motion ownership**
   a. Start a motion, then request another motion on the same property: the system identifies the active owner and applies the selected interruption behaviour
2. **Interruption outcomes**
   a. Start a motion using each supported interruption choice: the affected property reaches the result defined by that choice without simultaneous conflicting writes
   b. Queue a second motion behind an active motion: the queued motion starts only after the active motion's policy-defined outcome
3. **Showcase discovery**
   a. Open the demo selector and choose Showcase: Grid Showcase is listed and can be opened

## Validation Plan

### Questions

- **Q1.** Do the supported interruption choices make overlapping motion requests predictable enough to use without workarounds?
- **Q2.** Does the Showcase category make Grid Showcase easy to find?

### Try

- Start conflicting motions under each supported interruption choice and observe the resulting property state and playback outcome.
- Open the demo selector and find Grid Showcase through the Showcase category.

## Assumption Log

| ID | Assumption | Risk if wrong |
| --- | --- | --- |
| A1 | The general interruption choices in this phase can be extended by deferred visual-state and layout-transition work without introducing a separate conflicting model. | Later feature-specific interruptions require rework or produce inconsistent outcomes. |

## Acknowledged Risks

- Some interruption choices may need additional limits once they meet dynamic or feature-specific motion types.
- Grid Showcase is the only requested initial member of the new category, so its usefulness should be revisited as the demo library grows.
