### STORY-7k: Keyframes infer a missing starting value from the target's own live state

#### What and why
A keyframe motion that only declares a `"to"` step — `Anima.on(node).keyframes({"to": {"scale": Vector2(2.0, 2.0), "opacity": 0}})` — now actually animates from wherever the node's scale and opacity already are up to the declared end values, instead of the property just sitting at the end value for the whole motion with nothing visibly happening. This restores behaviour Anima v1 already had.

#### Done when
- [ ] A keyframe track with no stop declared at the start (no `"from"`, no literal `0`) animates from the target's own current value for that property at the moment the motion starts, into whichever stop comes first.
- [ ] A track that *does* declare an explicit starting stop (`"from"` or literal `0`) is completely unaffected — it still starts from exactly the authored value, never the target's live one.
- [ ] The same inference applies identically whichever way the keyframes were authored — the dictionary form passed to `.keyframes(...)`, and stops added incrementally via `.at(...)`.
- [ ] Test: reversing a playback built from a track with an inferred starting value still produces a working reversed motion — no crash, no missing segment.

#### Not this story
- `AnimaPropertyMotion`'s own separate "no `from` supplied" behaviour (`AnimaPropertyMotionInstance`'s live-value capture on first `advance()`) — an existing, different mechanism, untouched by this story.
- Reversal re-using a previously-resolved dynamic value instead of recomputing it against a possibly-since-changed target — already a separate, deferred phase-level item (phase brief's Not This Phase / Assumption Log); this story does not change that behaviour.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_keyframe_motion.gd` (the shared parse/merge path both `Motion.keyframes()` and `.at()` funnel through — after merging and sorting a track's stops, synthesise an offset-`0.0` stop when none exists)
- **Contract:** `tech-spec.md` §Keyframe motions, "Implicit initial value (v1 parity)" — exact synthesis condition (`no stop at offset 0.0`), the synthesised stop's value (`AnimaValue.target(track.property_path)`), and its `ease` (stays `null`, never consulted)
- **Do not:** synthesise a stop when the track already has one at offset `0.0`; touch `AnimaPropertyMotion`/`AnimaPropertyMotionInstance`'s own unrelated missing-`from` mechanism

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
