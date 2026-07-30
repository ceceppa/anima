# Phase Brief — Anima — Phase 4

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 3's own review flagged that the composition example reads as a presentation slide, not an interactive product demo, and that this class of problem is invisible to automated tests — only a visual pass catches it. This phase does that pass.

## Vision

Open the composition example and it should feel like a deliberate playground for Anima, not a set of controls scattered on a canvas. One compact header, one contained stage, a floating selector — and the cards themselves should tell the story of whichever composition type is running.

## Design Principle

When a visual change and the running animation's legibility conflict, the animation wins — UI chrome should support the demo, never compete with it for attention.

## Core Product Principles

- Motion should stay comprehensible: the editor (and here, the example) should always be able to show execution order and relationships — never just a black-box result.

## Phase Goal

The composition example reads as a polished interactive playground — a shared header, one bordered stage, and a floating selector dock — where the cards visibly demonstrate each composition type's behaviour instead of just completing together.

## Phase Scope

- Example scenes get a shared, reusable header (icon, title, subtitle) in place of each scene's own centred heading.
- The composition example's description, cards, and selector live inside one visually contained stage that stays stable across tab switches.
- The selected composition type shows its own short title and description inside the stage, with a subtle transition when switching.
- A shared, reusable selector dock component replaces today's selector, with an animated indicator that moves to the newly selected option.
- Cards distinguish resting, waiting, active, and completed states instead of showing a permanent glow.
- Each composition type's cards visibly demonstrate that type's behaviour (one-at-a-time, all-together, staggered offset, repeat-and-restart, race winner vs. interrupted).
- The stage background gets restrained visual depth behind the cards.
- Spacing across the header, stage, cards, and selector follows a deliberate hierarchy instead of loose, undefined gaps.
- Conditional returns to the selector, demonstrated with two cards (True / False) instead of last phase's single-branch presentation that was hidden for being confusing.

## Not This Phase

- Applying the new header/stage/selector components to any other example scene — only `composition_playground` exists today; "shared across every example" means built for reuse, not retrofitted elsewhere yet.
- Any change to the underlying composition runtime (Sequence/Parallel/Stagger/Repeat/Race/Conditional themselves) — this phase is visual/UX only.
- Restoring Conditional adds no new runtime capability; only its demo presentation changes.
- Deciding between the two background-depth treatments (gradient vs. dot/grid texture) as a final design choice — see Acknowledged Risks.

## Exit Criteria

1. Launch the example
   - Composition example opens: shared header visible (icon, title, subtitle), one bordered stage containing the description, cards, and selector dock
2. Switching composition type
   - Selecting a different type in the selector dock: indicator animates to the new option, title/description crossfade, cards restart to demonstrate the new type
3. Watching each type run
   - Sequence: cards activate one at a time, in order
   - Parallel: cards activate together
   - Stagger: activation visibly travels between cards
   - Repeat: cards show completion, then visibly restart
   - Race: one card reaches a clear winner state; the other stops short
   - Conditional: the True or False card shows which branch ran
4. Stability across switches
   - Header, stage, and selector position/size stay fixed no matter which type is selected

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The existing continuous progress-driven card model (`set_progress(t)`) can be re-skinned into resting/waiting/active/completed visuals without becoming a discrete state machine again. | If the states need genuinely discrete transitions, `StateCard`'s contract changes again, echoing Phase 3's earlier state-model rework. |
| "Shared component used by every example" is scoped this phase as reusable-and-applied-to-composition_playground, not retrofitted onto other scenes, since none exist yet. | If a second example scene is expected sooner than assumed, the reuse claim can't be verified until then. |

## Acknowledged Risks

- The background-depth treatment (radial gradient vs. dot/grid texture) isn't decided yet — left open for design or story time, per Not This Phase.
- Per-type card storytelling (Sequence vs. Parallel vs. Stagger vs. Repeat vs. Race reading as visibly distinct) is a perceptual judgment call — the same class of issue Phase 3's review found invisible to automated tests. This phase will need the same manual visual-inspection pass before being called done.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
