### STORY-7d: Pivot support for keyframe motions

#### What and why
A developer authoring a keyframed scale or rotation pulse anchors it to a corner or edge instead of the target's default origin — either by calling `.with_pivot(...)` once, or by declaring `_pivot` inline with whichever keyframe stop it reads most naturally next to, the same convenience Anima v1 offered — instead of having no way to anchor a keyframe transform at all.

#### Done when
- [ ] Calling `.with_pivot(...)` on a keyframe motion sets a pivot applied to the whole motion, anchoring its scale/rotation transform the same way `AnimaPropertyMotion.pivot` already does for a single-property motion.
- [ ] A keyframe dictionary declaring `_pivot` on one of its stops applies that same pivot to the whole motion, without needing `.with_pivot(...)` called separately.
- [ ] A keyframe motion with no pivot declared anywhere — neither `_pivot` nor `.with_pivot(...)` — animates exactly as it does today, with no anchor shift.
- [ ] `Anima.grid(container).with_pivot(...)` sets the currently-configured item motion's pivot and returns the factory, chainable the same way `.with_duration()`/`.with_ease()` already are.
- [ ] A plain (non-keyframe) property motion's existing pivot behaviour is visually unchanged, confirming the shared pivot logic move didn't alter what already shipped.
- [ ] The generated API reference documents pivot support on the keyframe motion and the grid factory's `.with_pivot()`.

#### Not this story
- A pivot that changes mid-animation as different stops play — pivot resolves once for the whole motion, matching `AnimaPropertyMotion.pivot`'s own existing constraint.
- Any change to `AnimaPropertyMotion`'s own public `.pivot` field or `.with_pivot()` signature — only its internal implementation is refactored to share code with keyframes, its observable behaviour is unchanged (see the regression AC above).

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_keyframe_stop.gd` (`pivot: Variant = null`); `addons/anima/motion/resources/anima_keyframe_motion.gd` (`default_pivot: AnimaPropertyMotion.Pivot = NONE`, `.with_pivot(value)`, `.at()`'s parser reads the `_pivot` reserved key); `addons/anima/motion/runtime/anima_motion_instance.gd` (new shared `_apply_pivot_to(target, pivot)`, plus the anchor table and `_supports_offset_pivot()` moved up from `AnimaPropertyMotionInstance`); `addons/anima/motion/runtime/anima_property_motion_instance.gd` (`_apply_pivot()` becomes a thin wrapper over the shared method, its own `scale`/`rotation` gate unchanged); `addons/anima/motion/runtime/anima_keyframe_motion_instance.gd` (resolve one pivot value per the scan order below, call the shared method); `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`with_pivot(value)`, same pattern as `with_duration`/`with_ease`)
- **Contract:** `tech-spec.md` §Motion pivot control ("Shared with keyframe motions"), §Keyframe motions ("Pivot" — exact resolution order: scan `tracks` in order, each track's `stops` in offset order, first non-`null` `_pivot` wins; `default_pivot` otherwise), §Keyframe interface, §Grid convenience shorthand
- **Tests:** `tests/AnimaKeyframeMotion.test.gd` (extend — `.with_pivot()` sets `default_pivot`, `_pivot` parses into the right stop); `tests/AnimaKeyframeMotionInstance.test.gd` (extend — resolved pivot is actually applied on advance, scan-order precedence when multiple stops declare `_pivot`, no-op when nothing is declared); `tests/AnimaPropertyMotion.test.gd` (existing pivot tests are this story's regression guard — must still pass unchanged after the shared-method refactor); `tests/AnimaGridMotionFactory.test.gd` (extend — `.with_pivot()` sets the right field per item-motion kind, errors on missing/incompatible item motion)
- **Do not:** support a pivot that changes value between stops within one resolved motion

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
