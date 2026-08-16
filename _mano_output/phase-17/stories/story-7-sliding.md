### story-7: Sliding entrance and exit presets

#### What and why
A user wanting a pure positional slide — no fade, no scale — reaches for a slide preset rather than a fade-and-slide one. This story ports v1's 8 sliding presets (4 entrances, 4 exits), each a position-only motion whose starting/ending offset depends on the target's own size.

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 slide behaviour end to end, with no opacity change at any point:
  - `slide_in_left` / `slide_in_right` / `slide_in_up` / `slide_in_down`: starts offset in the named direction by the target's own size, ends at its resting position.
  - `slide_out_left` / `slide_out_right` / `slide_in_up` / `slide_out_down`: starts at its resting position, ends offset in the named direction by the target's own size.
- [ ] A preset's resolved starting/ending offset changes when the target's own size changes, proving the offset is computed live, not a fixed literal.
- [ ] All 8 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Any other style group. In particular, do not add opacity to these presets — v1's sliding family is deliberately position-only, unlike the fading family.

#### Notes
Depends on story-1.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)`, `"from"`/`"to"` offsets — `tech-spec.md` §Keyframe motions ("Offset resolution").
- **Files:** `addons/anima/presets/entrance/` (the `_in` presets), `addons/anima/presets/exit/` (the `_out` presets) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/sliding_entrances/*.gd` and `addons/anima/animations/slide_exits/*.gd` in the v1 project.
- **Dynamic values:** each offset is `AnimaValue.target(...)`-based (own size only, no parent term) — canonical mapping convention, `project-rules.md` §Animation Catalog.
- **Rules:** one resolved-value unit test per preset, plus the target-size-change check above — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
