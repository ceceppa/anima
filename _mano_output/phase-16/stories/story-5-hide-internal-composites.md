### STORY-5: Internal composition classes hidden from the public surface

#### What and why
`AnimaSequence`, `AnimaParallel`, and similar internal composition plumbing currently show up in Godot's autocomplete and "New Resource" picker with the same visual weight as `Anima.on`/`Anima.group`/`Anima.grid` — the entry points an author is actually meant to reach for. Renaming them behind a leading-underscore convention keeps the intended convenience surface uncluttered without changing any animation behaviour.

#### Done when
- [ ] Test: `ProjectSettings.get_global_class_list()` lists `_AnimaSequence`, `_AnimaParallel`, `_AnimaRepeat`, `_AnimaRace`, `_AnimaConditional`, and `_AnimaStagger` as the registered global class names (not their previous unprefixed names)
- [ ] Test: every existing composed-chain scenario already covered by the suite (`Motion.sequence()`/`.then()`, `Motion.parallel()`/`.with()`, `Motion.repeat()`/`.repeat()`, and any Race/Conditional/Stagger coverage) still plays, completes, and reverses identically to before the rename
- [ ] Test: chaining an unresolvable argument into `.then()`/`.with()` still reports an error and returns `self` unchanged, unaffected by the rename

#### Not this story
- Renaming `AnimaGroupMotion`/`AnimaGridMotion` (stay public — they back `Anima.group()`/`Anima.grid()` directly), any leaf motion type (`AnimaPropertyMotion`, `AnimaKeyframeMotion`), or any runtime `*Instance`/`*Playback` class

#### Notes
Pure rename — see `tech-spec.md` §Key technical decisions and `project-rules.md` §Naming for the exact scope and the carve-out rule this story implements.

#### Implementation Reference
- **Build:** rename `class_name` on the six composite resource classes per `tech-spec.md` §Key technical decisions and `project-rules.md` §Naming; update every internal reference (`is`/type checks, typed fields, factory/builder construction) accordingly; file names stay unprefixed (`project-rules.md` §Naming)
- **Files:** `addons/anima/motion/resources/anima_sequence.gd`, `anima_parallel.gd`, `anima_repeat.gd`, `anima_race.gd`, `anima_conditional.gd`, `anima_stagger.gd`; every file referencing these types by name (runtime instance classes, the `Motion` builder, `_resolve_chainable()`)
- **Rules:** `project-rules.md` §Naming (new `_AnimaXxx` carve-out); §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
