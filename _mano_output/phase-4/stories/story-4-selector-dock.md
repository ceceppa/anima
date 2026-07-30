### STORY-4: Selector dock with animated indicator

#### What and why
Whoever chooses a composition type now taps a compact floating dock instead of a flat row of tabs — a single highlighted shape visibly slides to whichever type is tapped, so switching feels like moving a spotlight between options rather than each button independently lighting itself up.

#### Done when
- [ ] The composition-type selector renders as a compact dock centred below the cards, inside the stage — not a full-width bar
- [ ] Tapping a different type moves a single indicator shape to sit behind the newly selected type, while the previously selected label returns to its unselected colour/weight at the same moment
- [ ] Pressing down on a dock item visibly and briefly shifts that item (position or scale), returning to its resting look immediately after release
- [ ] The selected item combines a filled background, brighter text colour, and bolder font weight together (not colour alone); moving keyboard focus to an item without selecting it shows a focus indicator visually distinct from the selected look
- [ ] Test: calling `select(index)` on the dock moves the indicator to the item at `index` and marks exactly one item selected
- [ ] Test: calling `set_selected(true)` on a selector item changes only its label colour/weight — it does not render its own background fill

#### Not this story
- Restoring Conditional as a sixth dock item — story-8.
- The stage container itself — story-2.
- Card visual behaviour — stories 5–6.

#### Notes
Depends on story-2 (the stage exists for the dock to sit inside). Retires the previous flat selector strip's per-button self-fill behaviour entirely, per `project-rules.md`'s updated `SelectorDock`/`SelectorButton` split.

#### Implementation Reference
- **Design:** `design-brief.md` §Component guide "Selector dock" — indicator movement timing/easing, label transition timing, press feedback timing, §Border radius (`radius-dock`, `radius-md`), §Colour palette (`dock-bg`)
- **Contract:** `project-rules.md` §Example Scenes — `SelectorDock.select(index)`, `SelectorButton.set_selected(selected)` (label colour/weight only, no self-owned fill)
- **Files:** `examples/shared/components/selector_dock.tscn`, `examples/shared/components/selector_dock.gd` (new); `examples/shared/components/selector_button.gd` (update — remove self-owned fill logic); `examples/composition_playground.gd` (wire selection through the dock)
- **Test files:** `tests/SelectorDock.test.gd` (new), `tests/SelectorButton.test.gd` (update existing)
- **Do not:** no per-button background-fill logic inside `SelectorButton` (`project-rules.md` §Example Scenes)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
