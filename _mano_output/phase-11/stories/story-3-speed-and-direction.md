### STORY-3: Forward/reverse speed and direction

#### What and why
A developer who wants a UI panel to open slowly but close snappily currently has to author two separate motions with hand-tuned durations, because Anima has no idea a "closing" is the reverse of an "opening" it should just play faster. This story lets a single authored motion carry its own forward and reverse pace, and lets a developer speed up, slow down, or flip the direction of a motion that's already running, without it snapping or losing its place.

#### Done when
- [ ] A motion with different `forward_speed` and `reverse_speed` values plays at its `forward_speed` pace normally, and at its `reverse_speed` pace when played via `Anima.play_backwards()` or after `reverse()`
- [ ] Changing an in-progress playback's speed scales how quickly it proceeds without changing the authored duration recorded on the motion itself
- [ ] Calling `reverse()` mid-flight keeps the target at its current progress and value at the instant of the call — it does not jump to either end
- [ ] Reversing a playback more than once in a row keeps alternating direction correctly, using the matching `forward_speed`/`reverse_speed` each time
- [ ] A Group motion nested inside a Sequence, with both the group's own speed and the playback's own speed changed, advances at their combined (multiplied) rate together — not just the outermost speed alone
- [ ] Test: GUT unit tests on `AnimaPlayback`'s direction/speed composition; an integration test drives a nested Group-in-Sequence through `Anima.play()` with combined speed changes and asserts the combined rate
- [ ] Test: every new public field on `AnimaPlayback`/`AnimaMotion` has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- `forward_speed`/`reverse_speed` on a nested (non-root) motion — consulted at the playback root only this phase
- Progress-based seeking/scrubbing, and PROCESS/PHYSICS/UNSCALED clock-mode selection — separate backlog items, not selected into this phase
- Speed's effect on markers — markers don't exist yet
- Spring-specific speed scaling — story-4

#### Notes
Directly exercises the phase brief's Acknowledged Risk about the effective-speed multiplication chain (scope × playback × parent × local × direction) — the nested Group-in-Sequence test above is that verification.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_playback.gd` (`_is_reversed`; direction-aware effective speed applied at the top of `_advance()`); `addons/anima/motion/resources/anima_motion.gd` (`forward_speed`, `reverse_speed` fields)
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — the exact composition formula and where each term is consulted
- **Rules:** Naming, Testing, Documentation — same `project-rules.md` sections as story-1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
