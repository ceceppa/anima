# Phase Brief — Anima — Phase 22

## Why This Phase

Automatic layout motion needs to preserve Godot's layout decisions while making supported changes readable in motion. Visual scenarios make both layout transitions and interruption outcomes directly verifiable.

## Design Principle

Keep the final layout authoritative while motion makes the change easy to inspect.

## Core Product Principles

- Static motion compiles, dynamic motion stays dynamic: anything reducible to a native Animation should compile to one; anything needing runtime state (springs, retargeting, signal waits, layout, shared elements) stays Anima-native.
- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, seeking, removed targets, layout changes, skipped/reduced motion, property conflicts, and editor preview must all be defined, not left as edge cases.

## Phase Goal

Someone can watch supported layout changes animate to their final arrangement and compare every supported motion-interruption outcome in visual examples.

## Phase Scope

1. **Automatic layout transitions**
   a. **Visual transition** — a supported layout change animates from its previous visual arrangement to the final arrangement chosen by Godot.
   b. **Supported boundaries** — the transition works for Control nodes in standard containers, animating position and size within one viewport.
2. **Visual verification scenarios**
   a. **Layout demonstration** — a visual scenario shows a supported layout before, during, and after an automatic transition.
   b. **Interruption coverage** — visual scenarios demonstrate replace, retarget, queue, and reverse when a new motion request interrupts an active motion.

## Not This Phase

- 3D layout transitions, arbitrary custom drawing, and layout changes across viewports.
- Explicit or manual layout-transition authoring forms.
- Child insertion, removal, reparenting, and repeated layout retargeting during an active layout transition.
- New interruption policies beyond replace, retarget, queue, and reverse.

## Exit Criteria

1. **Automatic layout motion**
   a. Run the layout demonstration and trigger a supported layout change: every supported Control reaches Godot's final position and size without a visible snap.
   b. Inspect the completed layout demonstration: the final arrangement remains the one selected by Godot.
2. **Interruption scenarios**
   a. Run each interruption scenario: replace, retarget, queue, and reverse each show a distinct resulting motion outcome.
   b. Restart each interruption scenario: it returns to its defined starting state before the next run.

## Validation Plan

### Questions

- **Q1.** Are the automatic layout transition and each supported interruption outcome clear enough to verify by watching their visual scenarios?

### Try

- Run the layout demonstration, trigger its supported layout change, and watch it settle into the final arrangement.
- Run the four interruption scenarios and compare the outcome after the new motion request arrives.

## Assumption Log

| ID | Assumption | Risk if wrong |
|---|---|---|
| A1 | The supported Control and standard-container cases are enough to establish the first automatic layout-transition behaviour. | A later supported case could require reworking the initial behaviour rather than extending it. |

## Acknowledged Risks

- A supported layout change may expose visual edge cases that require a follow-up refinement.
- The four interruption outcomes may not cover every future motion-composition case.
