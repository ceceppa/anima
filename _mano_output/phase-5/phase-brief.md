# Phase Brief — Anima — Phase 5

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 4 closed out the composition example's visual polish. The runtime itself still has clear gaps from the original roadmap — easing only covers basic curves, with no springs, bounce, or elastic feel; there's no per-node config resource yet; and Phase 4's own review surfaced a third gap: hovering an Anima function in the Godot editor shows no description at all.

## Vision

Someone reaching for a spring-like feel should get a real spring, not just a basic curve — construct it, tune it, retarget it mid-flight, and it behaves like one. Someone who wants to animate a single node directly, without composing `AnimaMotion` resources by hand, should be able to write `Anima.of($Node).to(...)` and have it just work, and be able to attach a reusable config resource to that same node without subclassing it. And whatever they hover over in the editor along the way should explain itself.

## Design Principle

Extend the existing easing and authoring surfaces rather than adding new concepts — a spring is just another `AnimaEase` kind, and `Anima.of` is a thinner face on `Anima.play()`, not a parallel system.

## Core Product Principles

- Static motion compiles, dynamic motion stays dynamic: anything reducible to a native Animation should compile to one; anything needing runtime state (springs, retargeting, signal waits, layout, shared elements) stays Anima-native.
- Composition over inheritance: Anima attaches to ordinary Godot nodes. Users should never need AnimatedButton, AnimatedPanel, AnimatedContainer, or AnimatedLabel subclasses.

## Phase Goal

`AnimaEase` supports every advanced curve kind including parameterised, retargetable springs, authors can animate an ordinary node directly through `Anima.of(...)`, and a node can carry a reusable `AnimaBehaviour` config resource without subclassing — with in-editor hover help covering the entire public API.

## Phase Scope

- `AnimaEase` gains back/bounce/elastic/cubic-Bezier/curve-resource/callable-evaluator/decay/custom-sampled-curve kinds alongside its existing basic set.
- `AnimaEase` gains a spring kind, with both simple response/bounce parameters and an advanced physics parameter set.
- A spring motion reports when it has settled (configurable strictness) and can be retargeted mid-flight without resetting its current value or velocity.
- A lightweight `Anima.of($Node)` proxy exposes `enter()`/`exit()`/`to()`/`transition_to()` directly against an ordinary node, without the caller constructing `AnimaMotion` resources by hand.
- A per-node `AnimaBehaviour` config resource (identity, lifecycle, defaults, layout toggle, reduced-motion field) can be attached to an ordinary node and discovered later, without subclassing that node.
- Every existing and new public Anima class/function shows a real description when hovered in the Godot script editor.

## Not This Phase

- `AnimaBehaviour`-bound usage of `Anima.of()` — wiring the proxy to read an attached `AnimaBehaviour` automatically is separate follow-on work, tracked in the backlog.
- Any consumer of `AnimaBehaviour` beyond attaching and discovering it: no Inspector UI section, no undo/redo, no inheritance/override resolution (node → parent → scene theme → project default), no runtime-state separation (`AnimaNodeInstance`), and no working state-binding behaviour (Idle/Hover/Pressed/etc.) — the resource reserves a field for bindings, but that field does nothing yet.
- Deciding which spring parameter model (simple vs. advanced) is the default-visible one in any future Composer/Inspector UI — no such editor UI exists yet to make that choice concrete.
- Spring/easing reversal semantics (exact-timeline vs. physical-retarget reverse) — a separate, later reversibility epic.
- Markdown documentation pages for these new classes — that's the existing Documentation rule's job, tracked separately from the in-editor hover-help item.

## Exit Criteria

1. New easing kinds
   - Construct an `AnimaEase` with kind back/bounce/elastic/cubic-Bezier/curve-resource/callable-evaluator/decay/custom-sampled-curve and call `evaluate(t)`: each returns values matching that kind's curve shape (e.g. bounce overshoots and settles, elastic oscillates)
2. Springs
   - Construct a spring-kind `AnimaEase` with simple response/bounce parameters: the motion settles according to its configured completion mode
   - Retarget a still-moving spring to a new value: it continues from its current value and velocity instead of resetting
3. Anima.of proxy
   - Call `Anima.of($Node).to(...)` directly against a node already in the tree: the node animates the same way `Anima.play()` would
   - Call `.enter()`/`.exit()`/`.transition_to()` on the same proxy: each plays without the caller constructing an `AnimaMotion` resource by hand
4. AnimaBehaviour resource
   - Attach an `AnimaBehaviour` resource to an ordinary node: the node's class is unchanged (no subclass), and the behaviour is later discoverable from that node without the caller tracking it separately
5. In-editor help
   - Hover any public Anima class or function, old or new, in the Godot script editor: a real description appears instead of "no description available"

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The spring completion/retargeting model built this phase is the foundation the later reversibility epic (`playback.reverse()`, `retarget_to_start()`) will build on — this phase implements forward spring behaviour only, not reversal. | If reversal needs a different underlying spring representation than what ships here, the spring model may need reworking once the reversibility epic starts. |
| The standalone `Anima.of` proxy shipped this phase is a deliberately narrowed version of the PRD's full proxy, which also covers `AnimaBehaviour`-bound nodes — that integration is separate follow-on work, not this phase. | If `Anima.of`'s standalone shape doesn't accommodate reading an attached `AnimaBehaviour` cleanly, the follow-on integration may need to rework this phase's proxy shape. |
| `AnimaBehaviour`'s state-bindings field is scoped this phase as a reserved, non-functional slot — the deferred "State bindings for common control states" item is what actually makes it do anything. | If the field's shape doesn't match what the binding behaviour needs later, that later item may need to change the field instead of just building on it. |

## Acknowledged Risks

- Which spring parameter model (simple response/bounce vs. advanced physics) is the default-visible one in a future editor UI is an open spec question (backlog: "Open decision: spring parameter model exposed by default") — this phase can build both without resolving that UI-visibility question.
- Getting a spring's retargeting right (reading current value + velocity without resetting) is the most physics-sensitive part of this phase — wrong completion thresholds could make springs feel like they never settle, or settle too abruptly.
- The behaviour storage mechanism (node metadata + private discovery group vs. a hidden node) is also an open spec question (backlog: "Open decision: behaviour storage mechanism") — the source document recommends the metadata approach, but `mano spec` still needs to confirm it before implementation.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
