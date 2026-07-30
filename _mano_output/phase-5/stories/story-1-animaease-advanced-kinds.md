### STORY-1: AnimaEase advanced curve kinds

#### What and why
Whoever picks a curve `kind` on `AnimaEase` beyond the original basic set — back, bounce, elastic, cubic Bezier, a Godot `Curve` resource, a custom callable, decay, or a custom sampled curve — gets a real, correctly-shaped curve out of `evaluate(t)`, matching what that curve name promises, instead of only the five kinds Phase 1 shipped.

#### Done when
- [ ] `AnimaEase` with `kind = BACK` and `evaluate(t)`: the configured overshoot is visible near the curve's start or end, and `evaluate(0.0) == 0.0`, `evaluate(1.0) == 1.0`
- [ ] `AnimaEase` with `kind = BOUNCE`: `evaluate(t)` shows one or more dips back down before settling, and reaches `1.0` at `t = 1.0`
- [ ] `AnimaEase` with `kind = ELASTIC`: `evaluate(t)` oscillates around its final value before settling, with the oscillation controlled by the configured amplitude/period
- [ ] `AnimaEase` with `kind = CUBIC_BEZIER`: `evaluate(t)` follows the curve defined by the two configured control points, with `evaluate(0.0) == 0.0` and `evaluate(1.0) == 1.0`
- [ ] `AnimaEase` with `kind = CURVE`: `evaluate(t)` returns the same value as sampling the assigned Godot `Curve` resource at `t`
- [ ] `AnimaEase` with `kind = CALLABLE`: `evaluate(t)` returns whatever the assigned `Callable` returns for that `t`
- [ ] `AnimaEase` with `kind = DECAY`: `evaluate(t)` approaches `1.0` asymptotically at a rate controlled by the configured decay rate, without exactly overshooting past it
- [ ] `AnimaEase` with `kind = CUSTOM_SAMPLED`: `evaluate(t)` interpolates between the configured sample values at the corresponding position

#### Not this story
- `SPRING` — a stateful kind that doesn't implement `evaluate(t)` at all; built in story-2.
- Any editor UI for previewing or switching between kinds — no Composer/Inspector work this phase.

#### Notes
One AC per kind, matching the enum this story adds — kept as one story since it's a single cohesive extension of one class (`AnimaEase`), not eight unrelated features.

#### Implementation Reference
- **Data:** `tech-spec.md` §Data model `AnimaEase` row — exact new kind names, field names, and default values for each kind
- **Files:** `addons/anima/motion/resources/anima_ease.gd`
- **Test file:** `tests/AnimaEase.test.gd` (update existing), per `project-rules.md` §Testing
- **Do not:** no change to `evaluate(t)`'s contract or behaviour for the existing `LINEAR`/`POLYNOMIAL`/`SINE`/`EXPONENTIAL`/`CIRCULAR` kinds

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
