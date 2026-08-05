### STORY-6b: Reduced motion can mean "complete immediately," not just "slower"

#### What and why
A developer relying on reduced motion for a vestibular-sensitive user currently has only one option: play the same motion at a different speed. A slowed-down motion is still full motion, just stretched over more time — it doesn't serve the actual purpose reduced motion exists for. This story lets a motion's reduced-motion override mean "skip straight to the end" instead of "play slower," using the exact sentinel value the field already reserves for it.

#### Done when
- [ ] A motion with `reduced_motion_speed` set to `0.0` and reduced motion active jumps straight to its authored end value the instant it's evaluated, the same outcome `complete()` produces — not a very fast play-through, an actual skip
- [ ] The same completion contract applies: the completion callback fires, `finished` reports success, and `completion_value_policy` is respected, exactly as any other `complete()` call
- [ ] A motion with `reduced_motion_speed` set to a positive value still plays at that speed when reduced motion is active — no change from the existing behaviour
- [ ] A motion with `reduced_motion_speed` left at the default (`< 0.0`) is still unaffected by reduced motion — no change from the existing behaviour
- [ ] Every playground's demo motion switches from a slow reduced-motion speed to the "complete immediately" sentinel, so toggling reduced motion in a real playground visibly skips to the end instead of visibly slowing down
- [ ] Test: GUT unit coverage for the `0.0` sentinel alongside the existing positive-speed and no-override cases; update the playground integration test that currently asserts "reduced motion advances slower" to assert "reduced motion completes immediately" instead

#### Not this story
- The fuller per-motion reduced-motion policy (`FULL`/`SHORTEN`/`SIMPLIFY`/`COMPLETE_IMMEDIATELY` as named policy states) or swapping in an entirely different, simpler motion — still deferred, still backlogged
- Removing group stagger under reduced motion — unrelated to this field, not part of this story

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_playback.gd` (`_advance()`'s reduced-motion branch calls `complete()` and returns when `reduced_motion_speed == 0.0`); each of `examples/playground/composition_playground.gd`, `group_motion_playground.gd`, `convenience_motion_playground.gd`, `grid_motion_playground.gd`, `3d_motion_playground.gd` (switch their `reduced_motion_speed = 0.3` to `0.0`); `examples/playground/composition_playground.gd`'s own decoupled Card-visual clock also needs its reduced-motion branch to jump straight to the end, matching how it already had to duplicate the speed-override logic for story 6a
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — the `reduced_motion_speed == 0.0` sentinel paragraph
- **Rules:** Testing, Documentation — same `project-rules.md` sections as story-1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
