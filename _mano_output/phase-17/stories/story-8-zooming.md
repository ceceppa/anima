### story-8: Zooming entrance and exit presets

#### What and why
A user wanting a scale-driven entrance or exit — with or without a directional component — reaches for a zoom preset. This story ports v1's 15 zooming presets (9 entrances, 6 exits).

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 zoom behaviour end to end:
  - `zoom_in`: starts transparent and at a reduced scale, ends fully opaque at normal scale, with no positional change.
  - `zoom_in_left` / `zoom_in_left_big` / `zoom_in_right` / `zoom_in_right_big` / `zoom_in_up` / `zoom_in_up_big` / `zoom_in_down` / `zoom_in_down_big`: starts transparent, at a reduced scale, and offset in the named direction; ends fully opaque at normal scale and its resting position. The `_big` variant starts from a visibly larger offset than its non-`big` counterpart.
  - `zoom_out`: starts fully opaque at normal scale, ends transparent at a reduced scale, with no positional change.
  - `zoom_out_left` / `zoom_out_right` / `zoom_out_down` / `zoom_out_down_big`: starts fully opaque at normal scale and its resting position, ends transparent, at a reduced scale, and offset in the named direction. `zoom_out_down_big` ends at a visibly larger offset than `zoom_out_down`.
  - `zoom_out_up`: v1's own source never returns this one to a "gone" state — it ends fully opaque, at normal scale, offset upward by its own height. Port this incomplete-looking exit byte-for-byte, not as "ends transparent" like its siblings.
- [ ] All 15 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Any other style group. Note that v1 has no `zoom_out_left_big` / `zoom_out_right_big` / `zoom_out_up_big` — do not invent them; only the exact 15 names above exist in this catalog.

#### Notes
Depends on story-1.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/zooming_entrances/` (the `zoom_in*` presets), `addons/anima/presets/zooming_exits/` (the `zoom_out*` presets) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/zooming_entrances/*.gd` and `addons/anima/animations/zooming_exits/*.gd` in the v1 project.
- **Dynamic values:** directional offsets translate through `AnimaValue.*` using the canonical mapping convention established in story-3 — `project-rules.md` §Animation Catalog.
- **Rules:** one resolved-value unit test per preset — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
