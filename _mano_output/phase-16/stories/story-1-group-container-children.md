### STORY-1: Anima.group() plays a container's children

#### What and why
An author who wants to animate every child of a container node currently has to hand-build an `AnimaTargetCollection`/`AnimaGroupMotion` and call `Anima.play()` manually, even though `Anima.on()` and `Anima.grid()` already offer a one-line convenience factory for their own cases. `Anima.group(container)` gives group animation the same one-line entry point, configured and played the same fluent way `Anima.grid()` already is.

#### Done when
- [ ] `Anima.group(container).with_item_motion(motion).play()` animates every direct child of `container` using `motion`
- [ ] `Anima.group(container).keyframes({...}).with_duration(0.3).with_ease(AnimaEase.Kind.EASE_IN_OUT).play()` builds and plays a fully-configured keyframed item motion in one fluent statement, without a separate `AnimaKeyframeMotion`/`AnimaEase` construction step
- [ ] `Anima.group(container).with_item_motion(motion).with_delay(1.0).play()` doesn't start animating any child until 1 second after `.play()` is called
- [ ] `on_started`/`on_completed` callbacks passed to `.on_started()`/`.on_completed()` on an `Anima.group(...)` chain fire when the group's playback starts and finishes
- [ ] `Anima.group(container).with_item_motion(motion).then(Anima.on(other_node).fade_out(0.3)).play()` and `Anima.group(a).with_item_motion(m).with(Anima.grid(b).radial())` both compile and play, combining the group with another motion the same way `Anima.grid()` already can
- [ ] Test: `Anima.group(container).play()` with no item motion ever set reports an error and returns `null`, without playing an empty group

#### Not this story
- Passing an explicit array of target nodes instead of a container — separate story
- Any new group ordering, stagger, distribution, or distance-formula sugar beyond what `AnimaGroupMotion`'s existing fields already provide

#### Notes
None.

#### Implementation Reference
- **Build:** `Anima.group(targets: Variant) -> AnimaGroupMotionFactory` (`Node` dispatch branch this story) and the full `AnimaGroupMotionFactory` chain surface, per `tech-spec.md` §Group convenience shorthand (method table there)
- **Files:** `addons/anima/motion/runtime/anima_group_motion_factory.gd` (new); `addons/anima/motion/runtime/anima.gd` (`.group()` entry point); `tests/AnimaGroupMotionFactory.test.gd` (unit); `tests/Anima.integration.group-convenience.test.gd` (integration)
- **Rules:** `project-rules.md` §Testing; §Naming (`AnimaGroupMotionFactory` is a public entry-point factory, same category as `AnimaGridMotionFactory` — the `_AnimaXxx` internal carve-out does not apply to it); §Documentation (new public class/methods need `##` doc comments); §Derived Scheduling — do not add new ordering/scheduling logic here, delegate entirely to `AnimaGroupMotion`'s existing fields

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
