### STORY-2: Anima.group() plays an explicit list of targets

#### What and why
Some target sets aren't a container's children — an author may want to animate a hand-picked set of nodes together. `Anima.group([$A, $B, $C])` reuses the exact same factory and chain surface story-1 built, resolved against an explicit array instead of a container's children.

#### Done when
- [ ] `Anima.group([$A, $B, $C]).with_item_motion(motion).play()` animates exactly those three nodes and no others
- [ ] An array entry that isn't a `Node` is reported as an error naming the invalid entry, and the rest of the array still animates normally
- [ ] Test: `Anima.group(null)` and `Anima.group("not a node")` each report an error and return `null` immediately, the same fail-fast contract `Anima.on(null)` already has
- [ ] Every chain method story-1 covered (`.with_item_motion()`, `.keyframes()`, `.with_delay()`, `.on_started()`/`.on_completed()`, `.then()`/`.with()`) works identically on the array-built factory

#### Not this story
- Any new array-specific ordering or filtering beyond `AnimaGroupMotion`'s existing fields

#### Notes
Depends on: story-1 (same `AnimaGroupMotionFactory`; this story only adds the `Array` dispatch branch).

#### Implementation Reference
- **Build:** `Array` dispatch branch of `Anima.group(targets: Variant)`, per `tech-spec.md` §Group convenience shorthand
- **Files:** `addons/anima/motion/runtime/anima_group_motion_factory.gd` (extend `_init()`'s dispatch); `tests/AnimaGroupMotionFactory.test.gd`; `tests/Anima.integration.group-convenience.test.gd`
- **Rules:** `project-rules.md` §Testing; §Documentation (doc comment for the `Array` input form)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
