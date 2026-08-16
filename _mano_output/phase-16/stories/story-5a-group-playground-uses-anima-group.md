### STORY-5a: Group motion playground uses Anima.group()

#### What and why
The group motion playground still hand-builds an `AnimaTargetCollection` and calls `Motion.group()` directly instead of going through the phase's own `Anima.group()` convenience factory — so nothing shipped in this phase actually exercises Exit Criterion 1 (the group convenience API), leaving it unvalidated at review. Rebuilding the playground's group construction through `Anima.group(_card_row)` gives that criterion a real, exercised example, the same way the grid/dynamic-values playgrounds already exercise `Anima.grid()`.

#### Done when
- [ ] The playground's group animation is built via `Anima.group(_card_row)` (the container form — `_card_row` is the same `HBoxContainer` `_cards()` already reads its children from) instead of hand-constructing `AnimaTargetCollection`/calling `Motion.group()` directly.
- [ ] Every existing playback-mode selection (Sequential, Parallel, Staggered) still produces the identical animation behaviour as before this change.
- [ ] Every existing ordering selection (First, Last, Center, Odd, Even, Random, Index) still produces the identical animation behaviour as before this change.
- [ ] Restart, reverse, complete, revert, speed selection, and reduced-motion toggle all still work exactly as they did before this change.
- [ ] Test: the playground's built motion resolves the exact same target set (`_card_row`'s children) it did before this change, confirming `Anima.group()`'s container form is what's actually driving the playground now.

#### Not this story
- Exercising `Anima.group()`'s explicit-array form (`Anima.group([...])`) in this playground — that form is already covered by story-2's own unit/integration tests; this story only closes the gap for the container form, which had no example usage anywhere.
- Any new playback mode, ordering, or visual control beyond what the playground already offers.

#### Notes
Found during `mano review` for this phase: Exit Criterion 1 ("group convenience API") could not be validated because no shipped example calls `Anima.group()` at all.

#### Implementation Reference
- **Build:** replace `_build_group()`'s manual `AnimaTargetCollection`/`Motion.group()` construction with `Anima.group(_card_row)`, per `tech-spec.md` §Group convenience shorthand — `.with_item_motion(item)` sets the item motion currently built inline (`Motion.to(NodePath("progress"), 1.0).with_duration(0.42)` with `from_value = 0.0`); `playback_mode`, `distribution.stagger_interval`, `reverse_order_policy`, `order`, `target_collection.filter`, and `reduced_motion_speed` are still reached via `.motion` (`AnimaGroupMotionFactory.motion -> AnimaGroupMotion`, same section) exactly as `_configure_order()` already does today, since none of those fields have their own factory chain method
- **Files:** `examples/playground/group_motion_playground.gd` (`_build_group()`); its existing test file if one exists, otherwise a new minimal test confirming the resolved target set
- **Rules:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
