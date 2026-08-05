### STORY-1: AnimaKeyframeMotion resource, tracks, and offset parsing

#### What and why
A developer describing a multi-stop animation — fade in, hold, then slide, for example — currently has to hand-compose a Sequence of separate property motions instead of describing the whole shape in one place. This story gives them the data model for that: a keyframe motion that holds one or more properties at named/percentage offsets, parsed correctly regardless of how the offsets were declared or ordered.

#### Done when
- [ ] Declaring `{"from": {...}, "to": {...}}` produces one track per declared property, each with two stops at offset `0.0` and `1.0`
- [ ] Declaring a plain number offset (e.g. `50`) resolves to `0.5`; `"from"`/`"to"` resolve to `0.0`/`1.0`
- [ ] Declaring a grouped offset (e.g. `["from", 10]: {...}`) produces a stop at both `0.0` and `0.1` on every property in that block, with identical values
- [ ] A track's stops end up sorted by offset regardless of the order the dictionary keys were declared in
- [ ] A single value dict declaring two properties (e.g. `opacity` and `position`) produces two separate tracks, each getting a stop at that offset
- [ ] A semantic property name (`opacity`, `position`, `scale`, `rotation`, `color`, `size`) resolves to its canonical property path; an arbitrary property path string is also accepted directly
- [ ] A reserved `_ease` key sets that stop's own easing; unrecognised reserved-style keys (`_hold`, `_marker`, `_callback`) are accepted without error and never treated as a property
- [ ] Two declarations resolving to the same offset on the same property is a validation error, not a silent overwrite
- [ ] A motion with no tracks, or a track with no stops, fails validation
- [ ] Test: GUT unit coverage for offset resolution, grouped offsets, sorting independent of declaration order, multi-property stops, reserved-key handling, and the duplicate-offset and empty-track validation errors
- [ ] Test: every new public class, method, and field has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- Playing or evaluating a keyframe motion — this story is the data model and parser only; see story 3
- The fluent `.at()`/`Motion.keyframes()`/`Anima.on().keyframes()` authoring surfaces — see story 2
- Reversal — see story 4
- Dynamic (non-literal) keyframe values — depends on `AnimaValue`, not built; out of phase

#### Notes
`AnimaKeyframeMotion`/`AnimaKeyframeTrack`/`AnimaKeyframeStop` are all new `Resource` subtypes — the same pattern `AnimaTargetCollection`/`AnimaGroupDistribution`/`AnimaGroupOrder` already use as `@export` sub-resources.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_keyframe_motion.gd`, `addons/anima/motion/resources/anima_keyframe_track.gd`, `addons/anima/motion/resources/anima_keyframe_stop.gd`
- **Contract:** `tech-spec.md` §Keyframe motions — data model, offset resolution rules, multi-property/reserved-key handling; §Convenience method interface's canonical-mapping column for the semantic-name → property-path table
- **Data:** `tech-spec.md` Data model — `AnimaKeyframeMotion`/`AnimaKeyframeTrack`/`AnimaKeyframeStop` rows
- **Rules:** Naming — `project-rules.md` §Naming (`Anima`-prefixed `class_name`, file name mirrors class name); Testing, Documentation — same sections as prior phases' stories
- **Do not:** implement the parser as something developers call directly — "developers never call the flattening engine directly" (tech-spec.md §Keyframe motions); it's internal to the authoring surfaces story 2 exposes

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
