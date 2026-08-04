### STORY-5: Add relative property motions and a duration default chain

#### What and why
Motion authors can animate an arbitrary property relative to its current value the same way `move_by()`/`rotate_by()` already do, instead of only being able to set an arbitrary property to an absolute destination. When they don't specify a duration, it now falls back to a sensible per-node or global default instead of defaulting to zero.

#### Done when
- [ ] Chaining `.property_by(path, delta)` on `Anima.on()` animates that property relative to its value when the motion begins, the same way `.move_by()` does for position.
- [ ] Omitting duration on any convenience motion uses the target's attached node-level default duration when one is set.
- [ ] Omitting duration with no node-level default falls back to the global default duration.
- [ ] Explicitly setting `.with_duration()` always wins over both defaults.
- [ ] Changing the node-level or global default after a motion is authored, but before it plays, changes what an omitted-duration motion actually plays with.
- [ ] Test: `.property_by()` produces the same relative-motion result as `.move_by()`/`.rotate_by()` for an equivalent property.

#### Not this story
- A motion-theme default layer — deferred, `AnimaMotionTheme` doesn't exist yet, see `tech-spec.md`.
- Any change to how `AnimaBehaviour` itself is attached or read for other purposes.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_on_motion_factory.gd`; `addons/anima/motion/resources/anima_property_motion.gd`; `addons/anima/motion/runtime/anima.gd`; `tests/AnimaOnMotionFactory.test.gd`; `tests/AnimaPropertyMotion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract` (duration chain, `.property_by()` paragraphs); `§Convenience method interface`
- **Rules:** `_mano_output/project-rules.md §Naming`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
