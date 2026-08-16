### story-5: Back entrance and exit presets

#### What and why
A user wanting the "shrink then arrive" or "shrink then leave" entrance/exit feel (v1's "back" family) reaches for these presets instead of composing a scale+position motion by hand. This story ports v1's 8 back presets (4 entrances, 4 exits).

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 back behaviour end to end:
  - `back_in_down` / `back_in_up` / `back_in_left` / `back_in_right`: starts transparent, at reduced scale, and offset far in the named direction; arrives at its resting position while still at reduced scale and partially transparent, then grows to full scale and full opacity in place.
  - `back_out_down` / `back_out_up` / `back_out_left` / `back_out_right`: starts at full scale and full opacity at rest; shrinks and partially fades in place first, then moves off in the named direction while staying at that reduced scale and opacity.
- [ ] All 8 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Any other style group.

#### Notes
Depends on story-1.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/back_entrances/` (the `_in` presets), `addons/anima/presets/back_exits/` (the `_out` presets) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/back_entrances/*.gd` and `addons/anima/animations/back_exits/*.gd` in the v1 project.
- **Rules:** one resolved-value unit test per preset — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
