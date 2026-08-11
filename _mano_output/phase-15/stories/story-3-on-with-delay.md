### STORY-3: Anima.on() supports with_delay

#### What and why
A developer delaying a motion built through `Anima.on(...)` currently has to set `.delay` on the array element by hand instead of chaining it like every other modifier. `with_delay(...)` lets them set it the same way they already set duration and ease.

#### Done when
- [ ] `Anima.on(target).move_by(delta, duration).with_delay(seconds)` delays the motion's start by the given number of seconds
- [ ] Omitting `with_delay` leaves the motion starting with no delay, unchanged from today
- [ ] Test: `with_delay(0)` is accepted as a valid "no delay" value

#### Not this story
- Changing how delay composes with group or stagger delay elsewhere in the system

#### Notes
None.

#### Implementation Reference
- **Build:** `.with_delay(value: float)` modifier on `AnimaPropertyMotion`, setting the inherited `delay` field — already specified in `tech-spec.md §Convenience method interface` ("`with_delay(value: float)` is new, mirroring [`with_duration`/`with_ease`] for the inherited `delay` field")
- **Files:** `addons/anima/motion/resources/anima_property_motion.gd`
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — add the `##` doc comment for `with_delay`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
