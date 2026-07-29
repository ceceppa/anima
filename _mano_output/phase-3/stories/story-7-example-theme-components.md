### STORY-7: Example theme and shared components

#### What and why
A developer opening the example scene for the first time sees a composition actually animate with the product's real, modern look and feel — a dark themed scene with styled cards and a restart button — instead of the Godot editor's default, unthemed control styling. This story stands up the shared `Theme` resource and the two reusable components (`StateCard`, `PlaybackControls`) every future example scene will reuse, proven end-to-end with one working composition (Sequence).

#### Done when
- [ ] Opening `composition_playground.tscn` and pressing Play shows the scene styled with the custom Anima examples theme — dark background, styled cards and buttons — instead of the Godot editor's default control look.
- [ ] The scene shows one state card per node involved in the Sequence demo, each showing a bold single-letter label.
- [ ] While the Sequence demo plays, each state card's appearance updates from waiting to playing to completed as its node's motion starts and finishes.
- [ ] Pressing the restart button cancels the current playback and starts the same Sequence demo again from the beginning, with every state card resetting back to waiting first.
- [ ] Test: `StateCard.set_state()` transitions through waiting, playing, and completed, and each state maps to its themed appearance.

#### Not this story
- Only the Sequence composition type is wired this story — the selector and the remaining five types are added in story-8.
- No scrubbing/seeking, speed control, reduced-motion toggle, or easing-curve/direction picker — those belong to the fuller playground vision, a later phase (`ux-flow.md` "Not this scene yet").

#### Notes
Depends on story-6 (the `Motion` builder) — build the Sequence demo using the builder, not direct resource construction (`ux-flow.md` §Composition Example Scene: "Selecting a composition type builds that composition using the Functional builder API").

#### Implementation Reference
- **Design:** `design-brief.md` — full palette/typography/spacing/component guide (StateCard, restart button, screen composition order).
- **UX:** `ux-flow.md` §Composition Example Scene — what the user sees and can do.
- **Build:** build the Sequence demo using the `Motion` builder API (`Motion.sequence(...)`, `Motion.to(...)`), not direct resource construction.
- **Files:** `examples/shared/theme/anima_examples.tres`, `examples/shared/components/state_card.gd` (+ `.tscn`), `examples/shared/components/playback_controls.gd` (+ `.tscn`), `examples/composition_playground.tscn` — `project-rules.md` §Example Scenes folder pattern.
- **Rules:** `StateCard` state enum (`WAITING | PLAYING | COMPLETED`) + `set_state(state, label)` contract — `project-rules.md` §Example Scenes.
- **Rules:** plain component naming (`StateCard`, `PlaybackControls`, no `Anima` prefix) — `project-rules.md` §Example Scenes naming rule.
- **A11y:** `positive-fill` restricted to large/bold display text only — `project-rules.md` §Example Scenes contrast rule; `StateCard`'s single large letter is the sanctioned use.
- **Testing:** `tests/StateCard.test.gd` — `project-rules.md` §Testing.
- **Do not:** wire any composition type besides Sequence yet; add scrub/speed/reduced-motion controls.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
