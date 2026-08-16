### story-4: Bouncing entrance and exit presets

#### What and why
A user wanting a springier, overshooting entrance or exit than a plain fade reaches for a bounce preset. This story ports v1's 10 bouncing presets (5 entrances, 5 exits).

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 bounce behaviour end to end:
  - `bouncing_in`: starts transparent and smaller than normal, overshoots past its normal size more than once, and settles at full opacity and normal size in place.
  - `bouncing_in_left` / `bouncing_in_right` / `bouncing_in_up` / `bouncing_in_down`: starts offset in the named direction, overshoots past its resting position, and settles at rest and fully opaque.
  - `bounce_out`: starts at normal size and full opacity, overshoots larger before shrinking away, and ends transparent.
  - `bounce_out_up` / `bounce_out_down`: starts at rest and fully opaque, overshoots slightly before moving off in the named direction, and ends transparent and offset.
  - `bounce_out_left` / `bounce_out_right`: v1's own source keeps these fully opaque throughout (unlike the other four bounce-out presets) — starts at rest, overshoots slightly, then flies far off in the named direction while staying visible. Port this opacity behaviour as-is, not as "ends transparent."
- [ ] All 10 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Any other style group.

#### Notes
Depends on story-1.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)`, using per-stop `_ease` for the overshoot segments — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/entrance/` (the `_in` presets), `addons/anima/presets/exit/` (the `_out` presets) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/bouncing_entrances/*.gd` and `addons/anima/animations/bouncing_exits/*.gd` in the v1 project.
- **Dynamic values:** any size-dependent directional offset translates through `AnimaValue.*` using the canonical mapping convention established in story-3 — `project-rules.md` §Animation Catalog.
- **Rules:** one resolved-value unit test per preset — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
