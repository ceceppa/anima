### story-6: Rotating entrance and exit presets

#### What and why
A user wanting a spin-in or spin-out entrance/exit reaches for a rotate preset. This story ports v1's 10 rotating presets (5 entrances, 5 exits), including the corner-pivoted variants that rotate around a specific corner rather than their centre.

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 rotate behaviour end to end:
  - `rotate_in`: starts transparent and rotated, ends fully opaque and upright, rotating around its own centre.
  - `rotate_in_down_left` / `rotate_in_up_left`: starts transparent and rotated, ends fully opaque and upright, rotating around its bottom-left corner (v1's own source pivots both of these around the bottom-left, regardless of the "down"/"up" in the name).
  - `rotate_in_down_right` / `rotate_in_up_right`: same as above, rotating around its bottom-right corner.
  - `rotate_out`: starts fully opaque and upright, ends transparent and rotated, rotating around its own centre.
  - `rotate_out_down_left` / `rotate_out_up_left`: starts fully opaque and upright, ends transparent and rotated, rotating around its bottom-left corner.
  - `rotate_out_down_right` / `rotate_out_up_right`: same as above, rotating around its bottom-right corner.
- [ ] All 10 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Any other style group.

#### Notes
Depends on story-1.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)`; the corner-pivoted variants set `default_pivot` (`TOP_LEFT`/`TOP_RIGHT`/`BOTTOM_LEFT`/`BOTTOM_RIGHT`) — `tech-spec.md` §Keyframe motions ("Pivot"), §Motion pivot control.
- **Files:** `addons/anima/presets/entrance/` (the `_in` presets), `addons/anima/presets/exit/` (the `_out` presets) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/rotating_entrances/*.gd` and `addons/anima/animations/rotating_exits/*.gd` in the v1 project.
- **Rules:** one resolved-value unit test per preset, including a check that a corner-pivoted preset's pivot resolves to the named corner — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
