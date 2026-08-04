# Phase Brief — Anima — Phase 11

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 10 fixed a reverse-playback bug without ever defining cancel/complete/revert/reverse as a coherent contract, and closed with an unresolved assumption about that fix's scope boundary. This phase settles both by turning "reverse mostly works" into fully specified playback control.

## Vision

Right now, once a motion starts playing, there's no reliable way to stop it cleanly, undo it, or change its speed mid-flight without something going wrong under the hood. This phase makes every one of those actions safe and predictable, so playback behaves the same way every time it's cancelled, completed early, sped up, or reversed.

## Design Principle

When a playback action's final state or cleanup is ambiguous, define it explicitly rather than leaving it as an implicit edge case.

## Core Product Principles

- Production-ready by default: interruption, reversal, and direction/speed changes must all be defined, not left as edge cases.
- Graceful degradation: optional integrations fail safely.

## Phase Goal

Any active playback can be cancelled, completed, reverted, or reversed — and have its speed or direction changed mid-flight — with a fully defined final state and no leaked resources.

## Phase Scope

- `cancel()` / `complete()` / `revert()` / `reverse()` as four distinct playback operations, each with a defined final state
- Configurable completion policy (KEEP_FINAL / RESTORE_INITIAL) and cancellation policy (KEEP_CURRENT / RESTORE_INITIAL / COMPLETE)
- Pre-animation snapshot capture sufficient to support `revert()`, `reverse()`, and `complete()`
- Guaranteed cleanup on cancellation: signals disconnected, property ownership released, pending callbacks stopped, runtime records cleared, exactly one terminal result emitted
- Forward/reverse speed multipliers and a general playback speed multiplier, composing correctly across item, group, and playback levels
- Speed kept strictly separate from direction — negative speed never means reverse; mid-flight direction changes preserve progress without snapping or re-resolving dynamic values
- Group-level speed scaling applied to a group's entire generated schedule as one coherent unit
- Spring motions scale simulation delta rather than timeline position, preserving authored spring character
- Manual clock stepping respects effective speed
- A minimal global reduced-motion flag (on/off) that a motion's speed override reacts to
- Lifecycle-safe default policies for: target freed, playback root freed, target hidden, scene tree paused, target reparented

## Not This Phase

- Progress-based seeking/scrubbing (`get_progress` / `set_progress` / `seek_time`) — separate backlog item, not selected
- Playback clock modes beyond manual stepping (PROCESS / PHYSICS / UNSCALED) — separate backlog item, not selected
- Speed effect on markers — markers don't exist yet
- The full reduced-motion policy system (per-motion FULL/SHORTEN/SIMPLIFY/COMPLETE_IMMEDIATELY, tri-state System/Enabled/Disabled) — this phase adds only a minimal on/off flag to unblock the speed override
- Motion Inspector/Composer display of composed speed values — the composition math ships; the visual breakdown waits for the Composer
- The "layout target removed" lifecycle case — waits for layout transitions
- Snapshot use by layout transitions, dynamic-value reversal, or editor preview — snapshots ship scoped to revert/reverse/complete only

## Exit Criteria

1. Playback control in the motion playground
   - Cancel a motion mid-flight: it stops, current visual values are kept per the cancellation policy, no lingering signal connections or ownership
   - Call `complete()` on a running motion: final values apply immediately, completion fires exactly once
   - Call `revert()` on a running motion: the target returns to its pre-playback state
   - Call `reverse()` mid-flight: playback runs backward from the current progress, not from the end
2. Speed and direction
   - Change a playback's speed while running: duration scales accordingly, authored duration is untouched
   - Reverse direction mid-flight: progress is preserved exactly, no value snap
   - Toggle the global reduced-motion flag: an override-eligible motion completes immediately or applies its reduced-motion speed
3. Group and spring behaviour
   - Change speed on a running group motion: every child's timing scales together as one schedule
   - Change speed on a running spring motion: settle characteristics are preserved, only real-time duration changes
4. Cleanup under stress
   - Free a node mid-playback: its motion cancels safely, no error, no leaked runtime entry
   - Pause the scene tree mid-playback: the motion follows its selected clock

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| A minimal on/off reduced-motion flag is a deliberately narrowed version of the deferred "Global reduced-motion setting" item (full System/Enabled/Disabled tri-state) | Phase 11's boolean model collapses a distinction the deferred item needs, forcing rework when the full tri-state setting ships |
| Group motions and spring motions already exist as shipped runtime capabilities from earlier phases | If either doesn't actually exist yet, the corresponding speed-scaling item can't be built as scoped |
| The existing motion playground (used to catch Phase 10's reverse/cleanup bugs) is available as the demo surface for this phase's exit criteria | If no such playground exists or lacks playback controls, exit criteria would need a different demo path |

## Acknowledged Risks

- Cancel/complete/revert/reverse touch nearly every existing motion type (property, group, spring, sequence, parallel) — regression risk spans all of them, not just new code paths
- Effective speed composition (scope × playback × parent × local × direction) is a nontrivial multiplication chain; getting the order or the direction-speed term wrong would silently mistime every nested motion

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
