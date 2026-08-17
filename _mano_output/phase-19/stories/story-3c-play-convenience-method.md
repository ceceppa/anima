### story-3c: Guides and Tutorials use `.play()`, not `Anima.play(motion, target)`

#### What and why
Every code example in the Guides and Tutorials sections currently plays its motion with `Anima.play(motion, $Target)`, even though every one of those motions is built through `Anima.on($Target)` and already captured its target — `.play()`, chained directly on the motion, is the shorter, intended form for that case. This story rewrites those examples to use it, so a newcomer copying an example sees the convenience form the rest of the addon's own documentation favours.

#### Done when
- [ ] Every code example in the Guides section that plays a motion built via `Anima.on(...)` calls `.play()` directly on that motion, instead of passing it to `Anima.play(motion, target)`.
- [ ] Every code example in the Tutorials section that plays a motion built via `Anima.on(...)` calls `.play()` directly on that motion, instead of passing it to `Anima.play(motion, target)`.
- [ ] The one example in Guides that plays a duplicated catalog preset (`Anima.animation(name).duplicate(true)`, which never captured a target) is left calling `Anima.play(motion, target)` — `.play()` would error on it, since it was never built through `Anima.on()`.

#### Not this story
- No change to the Features or Installation sections — they have the same `Anima.play(motion, target)` pattern in one example each (`built-in-animations.md` plays a bare `Anima.animation(...)` catalog preset, which can't use `.play()` for the same reason as the duplicated-preset case above; `installation/_index.md` plays an `Anima.on(...)`-built motion and could switch, but wasn't named in this request). Flagged in Notes; not touched here.
- No change to prose that merely names `Anima.play()` as the underlying API (e.g. `guides/motion-composer/index.md`'s two references) — only runnable code examples are in scope.

#### Notes
`docs/content/docs/features/built-in-animations.md:13` and `docs/content/docs/installation/_index.md:34` have the same stylistic inconsistency but weren't named in this request — worth a follow-up if the site should be consistent everywhere, not just Guides/Tutorials.

#### Implementation Reference
- **Contract:** `AnimaMotion.play() -> AnimaPlayback` only succeeds when the motion carries a captured `convenience_target` (set by `Anima.on(target)`, and propagated through `.then()`/`.with()` when every combined motion shares the same target) — calling it on a motion with no captured target reports an error and returns `null`. `tech-spec.md` §Target-bound authoring contract and `addons/anima/motion/resources/anima_motion.gd`'s own `play()` doc comment own this contract.
- **Files and exact call sites to convert** (`Anima.play(motion, $Target)` → `motion.play()`):
  - `docs/content/docs/guides/keyframe-motion.md` — `Anima.play(pop, $Card)`
  - `docs/content/docs/guides/multiple-animations.md` — `Anima.play(one_after_another, $Card)`
  - `docs/content/docs/guides/reusable-vs-single-shot.md` — both `Anima.play(fade_in, $Card)` occurrences
  - `docs/content/docs/tutorials/01-basic-animation/index.md` — `Anima.play(fade_in, $Label)` and `Anima.play(slide_in, $Label)`
  - `docs/content/docs/tutorials/02-popup-animation/index.md` — `Anima.play(popup, $Label)`
- **File and call site to leave unchanged:** `docs/content/docs/guides/reusable-vs-single-shot.md`'s `Anima.play(my_tada, $Card)` — `my_tada` is `Anima.animation("tada").duplicate(true)`, never built through `Anima.on()`, so it has no captured target for `.play()` to use.
- **Do not:** don't convert `built-in-animations.md`'s or `installation/_index.md`'s examples (see Not this story); don't change any prose sentence that merely names `Anima.play()`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
