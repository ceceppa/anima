### STORY-8: Restore Conditional with True/False cards

#### What and why
Whoever wants to see Anima's Conditional composition type can select it again from the dock — hidden since the previous phase for being confusing — and now sees exactly two cards, "True" and "False," so which branch actually ran is obvious at a glance instead of ambiguous.

#### Done when
- [ ] Conditional appears as a sixth item in the selector dock, in the position it held before being hidden
- [ ] Selecting Conditional shows exactly two cards, labelled "True" and "False"
- [ ] Only one of the two cards — matching whichever branch the condition actually selected — animates and reaches full progress; the other card stays at rest the whole time
- [ ] The stage's example counter updates to reflect six total types (e.g. becomes "0X / 06") now that Conditional is included
- [ ] Test: selecting Conditional shows exactly one card at full progress and one card at 0.0 progress once the demo completes, with labels "True" and "False"

#### Not this story
- Changing `AnimaConditional`'s own runtime behaviour (`tech-spec.md` §Data model) — this story only restores its demo presentation.
- Any UI for authoring or previewing the condition callable itself — out of scope this phase.

#### Notes
Depends on story-3 (counter — updates its total from five to six), story-4 (dock — adds the sixth item), and story-5 (StateCard — drives both cards' looks). Updates the fixed counter total introduced in story-3.

#### Implementation Reference
- **Design:** `design-brief.md` §Screen composition (Conditional: True/False cards)
- **Data — per-type copy** (new this story, not yet defined in any artifact): a one-line description for Conditional consistent with the others' phrasing, e.g. "Picks one of two animations based on a condition." — pick wording consistent with story-3's list; this is new copy, not sourced from an existing artifact.
- **Files:** `examples/composition_playground.gd` — include Conditional as a selectable type in the selector dock (currently not offered as a selection); ensure a Conditional demo exists driving two `StateCard`s labelled "True"/"False"
- **Test file:** `tests/Anima.integration.composition_playground.test.gd` (update existing)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
