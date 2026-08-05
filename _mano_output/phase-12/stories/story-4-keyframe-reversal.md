### STORY-4: Keyframe reversal with easing mirroring

#### What and why
A developer who reverses a keyframe motion — the same `reverse()`/`play_backwards()` every other motion kind already supports — currently gets nothing, since keyframes don't participate in the reversal contract yet. This story closes that gap, and does it properly: a reversed segment doesn't just replay the same easing shape backward, it visually eases the way a truly-reversed motion should (an accelerating segment reversed decelerates, matching the technique already proven in Anima v1).

#### Done when
- [ ] Reversing a literal-valued keyframe motion mid-flight plays it backward from its current progress, the same as every other motion kind
- [ ] Every stop's value ends up at the mirrored offset (`1.0 - original_offset`) after reversal
- [ ] A segment authored with a named easing (e.g. ease-in) reverses to its opposite (ease-out), not the same shape played backward — confirmed by comparing the reversed motion's actual eased curve against the expected mirrored shape, not just its start/end values
- [ ] A segment authored with an easing kind that has no mirror (e.g. linear, or an ease-in-out variant) is unaffected by reversal — same shape either direction
- [ ] "Backward playback for keyframe motions" no longer reproduces — reversing a keyframe motion produces a real backward run, not a no-op or an error
- [ ] Test: GUT unit coverage for `AnimaEase.mirrored()`'s full IN/OUT swap table and its no-op cases (linear, IN_OUT variants, parameterised kinds); a reversal test asserting the easing-ownership shift lands on the correct stop, not just that offsets flipped
- [ ] Test: `AnimaEase.mirrored()` and the reversal path have in-editor `##` doc comments, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- Mirroring `AnimaPropertyMotionInstance.build_reversed()`'s own easing — flagged as a separate backlog item ("Mirror easing on AnimaPropertyMotion reversal"), not touched here
- Dynamic-value reuse on reversal — deferred with `AnimaValue`

#### Notes
Depends on story 3 (needs a working, evaluable keyframe instance to reverse). The easing-ownership-shift algorithm is the subtle part here — read `tech-spec.md` §Keyframe motions' worked description carefully before implementing; "just mirror each stop's own easing in place" produces the wrong result.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_ease.gd` (`mirrored()`); `addons/anima/motion/runtime/anima_keyframe_motion_instance.gd` (`build_reversed()`)
- **Contract:** `tech-spec.md` §Keyframe motions — "Easing mirroring" and "Reversal (literal values only)" paragraphs for the exact IN/OUT table and the ownership-shift algorithm
- **Rules:** Testing, Documentation — same sections as story 1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
