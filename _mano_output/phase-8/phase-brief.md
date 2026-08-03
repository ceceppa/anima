# Phase Brief — Anima — Phase 8

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Comparing Anima 2 against the original addon surfaced real gaps — a much smaller easing vocabulary and no pivot control — and the Motion Composer itself turned out to have no way in from an ordinary node, leaving it effectively undiscoverable.

## Design Principle

Restore what the original Anima already proved useful before adding anything new.

## Core Product Principles

- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.
- Motion should stay comprehensible: the editor should always be able to show what's happening, not leave an author at a dead end.

## Phase Goal

A developer can author a motion with any of Anima v1's easing curves and an optional pivot point, reach the Motion Composer directly from a node carrying an Anima motion, and see a 3D Anima motion running in its own playground.

## Phase Scope

- Restore Anima v1's full easing curve library (Linear, Ease, and In/Out/In-Out variants of Sine, Quad, Cubic, Quart, Quint, Expo, Circ, Back, Elastic, Bounce) for every property motion.
- Motion pivot control for 2D (Control/Node2D) scale and rotation motions, choosing among the 9 v1 anchor positions instead of always transforming around the default origin.
- A visible entry point into the Motion Composer from selecting any node carrying an Anima motion, plus a clear next-step message whenever the panel has nothing to show.
- A new 3D playground scene, matching the shared header and playback controls of the existing playgrounds, showing an Anima motion on a 3D Icosahedron Card styled after the provided reference image.

## Not This Phase

- 3D pivot control — this phase's pivot capability covers 2D (Control/Node2D) motions only; Anima v1's pivot concept doesn't translate directly to Node3D.
- The fuller original Motion Composer vision (toolbar, editable structure tree, Inspector tabs, curve-preview panel, validation panel) — a different, much larger tool than what shipped; deferred as its own future phase.
- The fuller per-node Anima Inspector section (Enable Anima toggle, Lifecycle/Defaults/Layout/States/Shared Element/Accessibility groups) — only the Motion Composer entry point ships this phase.
- A dedicated easing-curve editor/preview tool — this phase restores the curve library itself, not an authoring tool for it.
- Retrofitting every existing 2D playground into 3D, or a broader set of 3D showcase scenes — this phase ships one 3D playground scene.
- Usability issues in the Motion Composer beyond the entry point (e.g. an empty graph, unclear group-vs-property-motion switching) — revisit after the entry point ships and real usage shows whether more is needed.

## Exit Criteria

1. Easing
   - Developer picks any of the restored easing kinds on a property motion: it plays with that curve's shape.
2. Pivot
   - Developer sets a pivot point on a 2D scale or rotation motion: the transform originates from the chosen point instead of the node's default origin.
3. Motion Composer entry point
   - Developer selects a node carrying an Anima motion: an "Anima" Inspector section offers Open Motion Composer.
   - Developer opens the Composer with nothing to show yet: a message states what to do next instead of a dead end.
4. 3D playground
   - Developer opens the 3D playground: the shared header, playback controls, and a 3D Icosahedron Card are visible.
   - Developer selects a motion family and plays it: the card visibly animates in 3D.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The Phase 8 3D playground is a minimal, single-scene precursor, not a fuller set of 3D showcase scenes already noted in the backlog. | Those richer scenes need capabilities (spatial group ordering, scrubbing, markers, camera support) this phase doesn't build; the Phase 8 scene's structure may not directly extend to them. |
| The Phase 8 Motion Composer entry point is a narrowed slice of the fuller per-node Anima Inspector section already noted in the backlog. | A reader could assume the full per-node behaviour section (Enable Anima toggle, Lifecycle/Defaults/Layout/States/Shared Element/Accessibility) ships this phase; only the entry point and next-step messaging do. |

## Acknowledged Risks

- The dock's confusion may run deeper than the missing entry point; once a developer can actually reach it, other dead ends (an empty graph, unclear group-vs-property switching) may still surface.
- Restoring 34 easing curves is a lot of curve math to get accurate; a subtly wrong curve shape is easy to ship unnoticed without a visual reference to compare against.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
