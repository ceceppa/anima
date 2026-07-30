### STORY-3: Spring retargeting

#### What and why
Whoever redirects a still-moving spring to a new destination — via `AnimaPlayback.retarget()` — sees it smoothly redirect from wherever it currently is, at whatever speed it's currently moving, instead of snapping back to its start and replaying from scratch.

#### Done when
- [ ] Calling `retarget()` on a playback whose motion is a single `SPRING`-eased `AnimaPropertyMotion`, while it's still moving, continues the motion toward the new value from its current position and current speed — it does not jump back to its original starting value
- [ ] After retargeting, the motion still reports itself finished according to its configured completion mode, now measured against the new target
- [ ] Calling `retarget()` on a playback whose motion is not a single spring-eased property motion (a non-spring ease, or a composite like `AnimaSequence`) does not silently succeed — it surfaces as an error the caller can notice
- [ ] Test: retargeting a spring twice in quick succession, before the first retarget has settled, still ends at the second, most recent target

#### Not this story
- Any UI for retargeting on demand outside code — not part of this phase.
- Reversing a spring (playing it backward) — a separate, later reversibility epic.

#### Notes
Depends on story-2 (spring simulation must exist before it can be retargeted).

#### Implementation Reference
- **Data:** `tech-spec.md` §Data model `AnimaPlayback` row (`retarget()` contract) and §Key technical decisions (retargeting changes the destination only, never resets current value/velocity)
- **Files:** `addons/anima/motion/runtime/anima_playback.gd`
- **Test file:** `tests/AnimaPlayback.test.gd` (update existing)
- **Do not:** no reset of current value or velocity on retarget; no support for retargeting composite motions or non-spring eases this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
