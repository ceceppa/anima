### story-1d: Typewrite duration scales with text length

#### What and why
`typewrite`'s reveal currently runs for the same fixed second and a half no matter what text it's playing against — a five-character label and a fifty-character label finish at the same moment, so the longer one visibly races through its characters while the short one crawls. V1 scaled `typewrite`'s duration by the target's own text length for exactly this reason; this story restores that behaviour for anyone browsing or using the ported preset, so the reveal pace reads the same regardless of how much text it's animating.

#### Done when
- [ ] Playing `typewrite` on two targets with different text lengths, started at the same time:
  - The target with the shorter text finishes revealing (fully visible) before the target with the longer text does.
  - Doubling one target's text length roughly doubles how long that target's own `typewrite` playback takes to finish revealing.
- [ ] Selecting `typewrite` from the `text` category in the Animation Catalog Playground still reveals the label's text from fully hidden to fully visible, unaffected by the underlying duration change.

#### Not this story
- No text-editing control added to the playground so a person can change the previewed target's text length live — this story's proof is the resolved-duration behaviour itself, verified directly (see Implementation Reference), not a new playground affordance.
- No change to any other preset's duration handling, or to `AnimaPropertyMotion.duration` — only `typewrite`/`AnimaKeyframeMotion` (`tech-spec.md` §Animation catalog).
- No widening of `AnimaGridMotionFactory`/`AnimaGroupMotionFactory`'s `.with_duration()` to also accept an `AnimaValue` — explicitly deferred (`tech-spec.md` §Key technical decisions).

#### Notes
Supersedes phase-17 story-9's "`typewrite`'s duration is explicit and fixed, not automatically scaled by the target's text length" line — that story stays `done` and unedited (story-immutability rule, `AGENTS.md` §Do not); this story is the actual re-port `mano spec` designed for (`tech-spec.md` §Animation catalog, "`AnimaKeyframeMotion.duration` accepts an `AnimaValue`...").

#### Implementation Reference
- **Build:** new `AnimaValue.length()` unary chain method (`Kind.LENGTH`) and `AnimaKeyframeMotion.duration`/`.with_duration()` widening `float` → `Variant` — `tech-spec.md` §Dynamic values ("Arithmetic composition") and §Animation catalog; exact contract in §Dynamic value interface and §Keyframe interface tables.
- **Files:** `addons/anima/motion/resources/anima_value.gd` (add `Kind.LENGTH`, `.length()`, its `resolve()` case), `addons/anima/motion/resources/anima_keyframe_motion.gd` (`duration`/`with_duration` type widen; `estimate_duration()` returns `AnimaDuration.dynamic()` when `duration is AnimaValue`), `addons/anima/motion/runtime/anima_keyframe_motion_instance.gd` (`_resolve_duration()` checks `is AnimaValue` before the existing `> 0.0` literal comparison and resolves through the existing `_resolve_dynamic()` seam), `addons/anima/presets/text/typewrite.tres` (re-authored `duration`).
- **Data:** `SPEED_PER_CHARACTER = 0.7` — v1 parity value: v1's `typewrite.gd` formula `"_duration": "{duration} * :text:length"` resolves `{duration}` to `ANIMA.DEFAULT_DURATION` (`anima-godot-4/addons/anima/core/constants.gd:93`, `0.7`) whenever no caller override is supplied, and this catalog's `.tres` has no caller-override path — so the ported literal is v1's own default, not an invented number.
- **Rules:** one resolved-value unit test for `typewrite` at representative offsets and text lengths — `project-rules.md` §Animation Catalog ("Each ported preset gets a unit test asserting its resolved keyframe values..."); general test coverage — `project-rules.md` §Testing.
- **Do not:** don't widen `AnimaPropertyMotion.duration` — it's a separately-declared field on a different leaf type and no property-motion preset needs this; don't widen `AnimaGridMotionFactory`/`AnimaGroupMotionFactory`'s `.with_duration()` this story.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
