### STORY-4: Spring speed scaling and manual stepping

#### What and why
A developer using one of Anima's spring-eased motions currently finds that changing playback speed has no visible effect on the spring — it settles at exactly the same pace no matter what. This story makes a spring's actual motion speed up or slow down along with everything else, and gives a developer a supported way to advance a motion by an exact amount themselves — for tests, tools, or frame-stepped debugging — instead of only ever being driven by the engine's own per-frame clock.

#### Done when
- [ ] Doubling the effective speed of a running spring-eased motion halves how long it takes to settle, while following the same authored spring character (no change in overshoot/oscillation shape)
- [ ] Halving the effective speed of a running spring-eased motion doubles how long it takes to settle
- [ ] Calling the new `step(delta)` method on a manually-constructed playback (one not driven by `Anima.play()`) advances it by exactly that amount, scaled by its effective speed the same way the automatic per-frame path already is
- [ ] Test: a GUT unit test measures a spring's settle time at 1x, 2x, and 0.5x effective speed and asserts the scaling relationship
- [ ] Test: a GUT test drives a motion purely through repeated `step()` calls with no `AnimaRuntime` involvement and asserts it completes
- [ ] Test: the new `step()` method has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for it

#### Not this story
- Physical retargeting (`retarget()`) — unaffected by this change, not touched
- Clock-mode selection (PROCESS/PHYSICS/UNSCALED) — deferred; `step()` is a direct-drive entry point only, not a mode switch

#### Notes
Depends on story-3's effective-speed composition (`speed_scale × direction_speed`) being in place — both the spring fix and `step()` consume it via the existing `_advance()`/`advance()` chain.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_property_motion_instance.gd` (`_advance_spring()` scaled-delta fix); `addons/anima/motion/runtime/anima_playback.gd` (`step(delta)`)
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — the "Spring simulation speed scaling" and "Manual stepping" paragraphs
- **Rules:** Testing, Documentation — same `project-rules.md` sections as story-1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
