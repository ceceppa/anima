### STORY-5: Anima.grid() supports with_delay

#### What and why
A developer delaying a grid motion's overall start currently has no `with_delay` (or `.delay`) entry point on `Anima.grid(...)`, unlike single-motion chains. Adding it lets a grid's start be delayed the same way any other motion's can.

#### Done when
- [ ] `Anima.grid(container).with_delay(seconds)` delays the grid motion's start by the given number of seconds
- [ ] Omitting `with_delay` leaves the grid starting with no delay, unchanged from today
- [ ] Test: `with_delay` composes independently of the grid's own per-item stagger/distribution delay — the overall start shifts, per-item relative timing stays the same

#### Not this story
- Changing per-item stagger timing itself

#### Notes
None.

#### Implementation Reference
- **Build:** `.with_delay(value: float)` modifier on the grid factory, setting the inherited `delay` field on the `AnimaGridMotion` it constructs (`tech-spec.md §Data model` — `AnimaMotion` base fields include `delay`, inherited by `AnimaGridMotion`)
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd`
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — add the `##` doc comment for `with_delay` on the grid factory

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
