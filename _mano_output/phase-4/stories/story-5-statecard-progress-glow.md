### STORY-5: StateCard glow reflects actual progress, not a permanent state

#### What and why
Whoever watches any composition demo now sees each card look genuinely at rest before its animation starts and settle back down once it finishes, instead of every card glowing the same way regardless of whether it's actually animating right now.

#### Done when
- [ ] Before a card's animation has started, it shows a plain outline with no glow
- [ ] While a card is actively animating, its glow is visibly stronger than both before it starts and after it finishes
- [ ] Once a card's animation finishes, its glow visibly reduces from the peak it reached while animating, rather than staying at that peak
- [ ] The same card component produces this look for every composition type in the selector — nothing about the card's own script branches on which type is selected
- [ ] Test: `set_progress(0.0)` produces no glow; a mid-range value produces more glow than `0.0`; `set_progress(1.0)` produces less glow than the mid-range value

#### Not this story
- Any notion of the card tracking a named state — `StateCard` has none (`project-rules.md` §Example Scenes: no state field, no state enum).
- Which composition type activates which card, and when — story-6.
- The header, stage, or selector dock — stories 1, 2, 4.

#### Notes
This addresses the original complaint that cards always look "active" no matter what's actually happening. The fix lives entirely inside `StateCard`'s existing continuous `set_progress(t)` mapping — not a new state model, not a per-card "waiting" flag.

#### Implementation Reference
- **Design:** `design-brief.md` §Component guide "StateCard" — glow rises then settles back down across the `t` range
- **Contract:** `project-rules.md` §Example Scenes — `StateCard` has no state; `set_label(text)` / `set_progress(t: float)` only
- **Files:** `examples/shared/components/state_card.gd`
- **Test file:** `tests/StateCard.test.gd` (update existing)
- **Do not:** no `set_state()`, no state enum, no per-composition-type branching inside `state_card.gd`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
