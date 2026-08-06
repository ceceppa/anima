### STORY-3: Dynamic values inside keyframes

#### What and why
A developer authoring a multi-step keyframe animation can set any keyframe's value to a dynamic value the same way a plain motion's `from`/`to` already can, instead of being limited to literal numbers at every step. This is what the RPG showcase's icon-pulse animation needs: every keyframe step in the pulse should reflect the icon's own real size, not one shared guess.

#### Done when
- [ ] A keyframe step whose value is a dynamic value resolves against the animated target the same way a non-keyframe motion's dynamic value already does.
- [ ] A keyframe motion with several steps, each carrying its own distinct dynamic value, resolves every step's value independently — one step's dynamic value never bleeds into another's.
- [ ] A keyframe motion mixing literal and dynamic values across its steps plays both kinds correctly in the same run.
  - [ ] Test: a keyframe motion using an arithmetic combination (story-2) as one of its step values resolves that combination the same way a plain motion using it would.
- [ ] The generated API reference's keyframe-step documentation states that a step's value may be a dynamic value, not only a literal.

#### Not this story
- Resolving a keyframe's dynamic value independently per item inside a group or grid — story-4.
- Reversal reusing a keyframe's previously-resolved dynamic value instead of recomputing it — a separate, already-backlogged item, not this phase.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_keyframe_stop.gd` (`value` is already `Variant`-typed — no field change needed); the keyframe motion's runtime instance under `addons/anima/motion/runtime/` (resolve each stop's `AnimaValue` once, the same "resolved once at motion start" moment story-1 establishes)
- **Contract:** `tech-spec.md` §Dynamic values ("Resolution timing"), §Keyframe motions ("Evaluation") — the resolved value substitutes for `stop.value` at evaluation time; the lerp/easing evaluation itself is unchanged
- **Tests:** `tests/AnimaKeyframeMotion.test.gd` (extend — dynamic-value stops, mixed literal/dynamic steps); `tests/Anima.integration.dynamic-values.test.gd` (extend — a keyframe motion played end-to-end with a dynamic step)
- **Do not:** implement group/grid per-item context in this story — a keyframe motion used as a group's item motion is story-4's concern

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
