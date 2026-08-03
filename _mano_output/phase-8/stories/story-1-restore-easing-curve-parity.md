### STORY-1: Restore easing curve parity

#### What and why
A developer choosing an easing curve — in code via `AnimaEase.Kind` or from the Motion Composer's ease dropdown — can pick from Anima v1's full curve vocabulary instead of a small subset, so a curve like "ease-in-out-back" that v1 supported has a name in Anima 2 too.

#### Done when
- [ ] Setting a property motion's ease `kind` to any of the 33 restored named curves (`EASE`/`EASE_IN`/`EASE_OUT`/`EASE_IN_OUT`, plus `EASE_IN_*`/`EASE_OUT_*`/`EASE_IN_OUT_*` for Sine, Quad, Cubic, Quart, Quint, Expo, Circ, Back, Elastic, and Bounce) plays that curve's distinct shape.
- [ ] The Motion Composer's ease picker lists every restored curve by name.
- [ ] Test: every restored curve evaluates to `0.0` at `t = 0` and `1.0` at `t = 1`.
- [ ] Test: for each curve family with an in/out/in-out triad, the "in" variant's value at `t = 0.5` differs from the "out" variant's value at the same `t`.

#### Not this story
- New tunable parameters for the restored curves — `Back`/`Elastic`/`Bounce`'s existing fields (`back_overshoot`, `elastic_amplitude`, etc.) are unchanged.
- Any change to the existing family-plus-parameter `Kind` values (`POLYNOMIAL`, `SINE`, `EXPONENTIAL`, `CIRCULAR`, `BACK`, `BOUNCE`, `ELASTIC`, `CUBIC_BEZIER`, `CURVE`, `CALLABLE`, `DECAY`, `CUSTOM_SAMPLED`, `SPRING`) or their current behaviour.
- Motion pivot control and the Motion Composer entry point — separate stories.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_ease.gd`; `tests/AnimaEase.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Easing curve library` — the exact 33 kind names and the `EASE`/`EASE_IN`/`EASE_OUT`/`EASE_IN_OUT` → quadratic-shape decision
- **Rules:** `_mano_output/project-rules.md §Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
