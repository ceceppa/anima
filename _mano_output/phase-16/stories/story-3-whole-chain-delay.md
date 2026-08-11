### STORY-3: Delaying an entire composed motion chain

#### What and why
An author who has already chained several `Anima.on()`/`Anima.grid()`/`Anima.group()` motions together with `.then()`/`.with()` can currently only delay the whole thing by repeating `with_delay()` on every individual leaf. This story lets them call `.with_delay()` once, directly on the composed chain, and have the entire thing wait that long before anything starts.

#### Done when
- [ ] Calling `.with_delay(seconds)` directly on a chain built via `.then()`/`.with()` (e.g. `Anima.on(a).move_by(...).then(Anima.on(b).fade_in()).with_delay(1.0).play()`) delays the whole chain's start by that many seconds — nothing animates until it elapses, and both steps then play in their original order exactly as they would without the delay
- [ ] The existing per-leaf `.with_delay()` (calling it on a single motion before combining it into a chain) is unaffected — it still only delays that one leaf/step, not the whole chain
- [ ] Test: a chain with no `.with_delay()` called on the composed chain itself starts immediately, unchanged from before this story

#### Not this story
- `.wait(seconds)` as an inline pause between chained steps — separate story
- Any change to `Anima.group()`/`Anima.grid()`'s own per-child stagger/distribution timing

#### Notes
None.

#### Implementation Reference
- **Build:** promote `with_delay(value: float) -> AnimaMotion` from a leaf-only method to the `AnimaMotion` base, per `tech-spec.md` §Key technical decisions (the `AnimaMotion.with_delay()` bullet); leaf overrides (`AnimaPropertyMotion`, `AnimaKeyframeMotion`) keep their existing narrower return types unchanged
- **Files:** `addons/anima/motion/resources/anima_motion.gd` (new base method); `tests/AnimaMotion.test.gd` (unit); `tests/Anima.integration.convenience-composition.test.gd` (integration, extend existing coverage)
- **Rules:** `project-rules.md` §Testing; §Documentation (doc comment on the new base method)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
