### STORY-2: Spring easing — construction, simulation & completion

#### What and why
Whoever configures an `AnimaEase` with `kind = SPRING` — using either the simple response/bounce parameters or the advanced mass/stiffness/damping physics parameters — gets a motion that actually behaves like a spring: it accelerates and decelerates toward its target and settles according to the configured completion mode, instead of running for a fixed duration like every other ease.

#### Done when
- [ ] A property motion using a `SPRING` ease (default simple parameters) moves toward its target with visible spring-like acceleration/deceleration rather than a constant-duration ramp, and reports `AnimaDuration.Kind.ESTIMATED` (never `FIXED`)
- [ ] Increasing `spring_bounce` visibly increases how far the motion overshoots its target before settling, compared to a lower value
- [ ] Switching `spring_model` to `ADVANCED` and configuring mass/stiffness/damping changes the settle behaviour accordingly (e.g. higher damping settles with less oscillation than lower damping)
- [ ] With `spring_completion_mode = STRICTLY_SETTLED` (the default), the motion is reported finished only once both its distance from the target and its velocity fall under the configured thresholds
- [ ] With `spring_completion_mode = FIXED_PREVIEW_DURATION`, the motion is reported finished after exactly `spring_preview_duration` seconds, regardless of the physical simulation's actual state
- [ ] With `spring_completion_mode = MANUAL`, the motion never reports itself finished on its own — it keeps running until the caller cancels or retargets it

#### Not this story
- Retargeting a still-moving spring to a new value — story-3.
- Reversing a spring (playing it backward) — a separate, later reversibility epic.
- Any editor UI for tuning spring parameters live.

#### Notes
Depends on story-1 only in the sense that both extend the same `AnimaEase` resource; no functional dependency between them. `VISUALLY_SETTLED` is part of the same `spring_completion_mode` enum as the three modes named in the AC above — implement all four modes; the AC above are the ones with an externally observable difference worth calling out individually.

#### Implementation Reference
- **Data:** `tech-spec.md` §Data model `AnimaEase` row (spring fields, defaults) and §Key technical decisions (spring is stateful, does not implement `evaluate(t)`)
- **Files:** `addons/anima/motion/resources/anima_ease.gd`; the runtime instance that advances a `SPRING`-eased `AnimaPropertyMotion` each frame (`addons/anima/motion/resources/anima_property_motion.gd` and its runtime counterpart)
- **Test file:** `tests/AnimaEase.test.gd` (update existing) for the spring fields/defaults; `tests/AnimaPropertyMotion.test.gd` (update existing) for the `ESTIMATED`-duration and completion-mode behaviour
- **Do not:** no `evaluate(t)` implementation for `SPRING` — it is stateful, not a pure function of normalized time (`tech-spec.md` §Key technical decisions)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
