### story-3h: Guide showing how simple Anima.on, Anima.group, and Anima.grid are

#### What and why
None of the six shipped Guides put `Anima.on()`, `Anima.group()`, and `Anima.grid()` side by side — a newcomer can't currently see, in one place, that animating one node, an explicit set of nodes, and a whole grid of nodes are each a short, similarly-shaped one-liner. This story adds that guide.

#### Done when
- [ ] The Guides section contains a new page showing all three entry points — `Anima.on()`, `Anima.group()`, `Anima.grid()` — each with its own runnable `gdscript` example animating something with it.
- [ ] The page states, in plain language, what each entry point is for (one node vs. an explicit set of nodes vs. a grid-shaped set of nodes) so a reader knows which one to reach for.

#### Not this story
- No change to any existing guide.
- No coverage of `Anima.item()` or the generic `.property()` escape hatch — those stay implicit in the existing guides that already touch `Anima.on()`.

#### Implementation Reference
- **Build:** new `docs/content/docs/guides/on-group-grid.md`, plain `.md` page — `tech-spec.md` §Documentation site structure (phase-19), `project-rules.md` §Documentation.
- **Data — `Anima.on()`:** single-target factory — `tech-spec.md` §Convenience method interface. Reuse a short example distinct from what `01-basic-animation`/`multiple-animations` already show (don't just repeat their exact snippet).
- **Data — `Anima.group()`:** `Anima.group(targets)` accepts either a container `Node` (its children become targets) or an explicit `Array` of targets; needs an explicit `.keyframes(...)`/`.with_item_motion(...)` before `.play()` works (no free default) — `tech-spec.md` §Group convenience shorthand.
- **Data — `Anima.grid()`:** `Anima.grid(container)` plus one named distance-formula preset (e.g. `.radial()`) is a complete, playable one-liner — those preset methods supply their own default item motion when none is set — `tech-spec.md` §Grid convenience shorthand ("Default `item_motion` — preset methods only").
- **Rules:** runnable-example requirement — `project-rules.md` §Documentation.
- **Do not:** don't introduce or imply any mechanism not already defined in `tech-spec.md`; don't duplicate the generated reference's member list — link to `../../anima/anima` instead.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
