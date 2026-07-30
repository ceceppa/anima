### STORY-6a: Documentation pages for every undocumented or changed class

#### What and why
Whoever reads Anima's documentation site finds a real page for every public class the addon ships — not just the ones this phase touched — and every page reflects the API that class actually has today, instead of the site describing an incomplete or outdated version of the public API.

#### Done when
New pages — classes with no page at all yet:
- [ ] `docs/content/docs/anima/anima-node-proxy.md` for `AnimaNodeProxy` (new this phase)
- [ ] `docs/content/docs/anima/anima-behaviour.md` for `AnimaBehaviour` (new this phase)
- [ ] `docs/content/docs/anima/anima-duration.md` for `AnimaDuration`, including the new `estimated()` constructor
- [ ] `docs/content/docs/anima/anima-conditional.md` for `AnimaConditional`
- [ ] `docs/content/docs/anima/anima-race.md` for `AnimaRace`
- [ ] `docs/content/docs/anima/anima-repeat.md` for `AnimaRepeat`
- [ ] `docs/content/docs/anima/anima-stagger.md` for `AnimaStagger`
- [ ] `docs/content/docs/anima/anima-conditional-instance.md` for `AnimaConditionalInstance`
- [ ] `docs/content/docs/anima/anima-race-instance.md` for `AnimaRaceInstance`
- [ ] `docs/content/docs/anima/anima-repeat-instance.md` for `AnimaRepeatInstance`
- [ ] `docs/content/docs/anima/anima-stagger-instance.md` for `AnimaStaggerInstance`
- [ ] `docs/content/docs/anima/anima-motion-builder.md` for `Motion`

Updated pages — classes with a page that no longer reflects the full API:
- [ ] `AnimaEase`'s existing page reflects every new curve kind added this phase (back/bounce/elastic/cubic-Bezier/curve/callable/decay/custom-sampled/spring) and the spring-specific fields, parameter models, and completion modes
- [ ] `AnimaPropertyMotion`'s existing page notes that a `SPRING`-eased motion reports `ESTIMATED` duration instead of `FIXED`
- [ ] `AnimaPlayback`'s existing page documents `retarget()`
- [ ] `Anima`'s existing page documents `of()`, `attach_behaviour()`, and `get_behaviour()`

#### Not this story
- The in-editor `##` GDScript doc comments — already done (story-6); this story is the separate markdown documentation site.
- Any restructuring of the documentation site itself, or its build/theme.

#### Notes
Attached as `6a` since story-6 was the last completed story in Phase 5. `AnimaSequence`, `AnimaParallel`, and their runtime instances already have pages and needed no changes from this phase — confirmed present, not part of this story.

#### Implementation Reference
- **Contract:** `project-rules.md` §Documentation — page location (`docs/content/docs/anima/<kebab-case-class-name>.md`), structure (front-matter, Overview, Inheritance, Availability, Quick example, then whichever of Properties/Methods/Signals/Enumerations/Constants apply), and the zero-prior-experience writing rule
- **Data:** `tech-spec.md` §Data model — exact field names, method signatures, and defaults for every class listed above
- **Files:** all listed above under `docs/content/docs/anima/`
- **Do not:** no code changes — this story only touches markdown under `docs/`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
