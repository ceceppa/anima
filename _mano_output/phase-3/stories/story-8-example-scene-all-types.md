### STORY-8: Example scene demonstrates every composition type

#### What and why
A developer exploring every Phase 3 composition type in one place selects Sequence, Parallel, Stagger, Repeat, Race, or Conditional from a strip of segments and immediately watches that composition play against the scene's demo nodes, with a duration readout showing what kind of duration it reports. This is the phase's example scene delivering on its full exit criterion — every composition type from this phase, visibly running.

#### Done when
- [ ] The composition-type selector shows all six types (Sequence, Parallel, Stagger, Repeat, Race, Conditional) and selecting any one of them builds and plays that composition via the Motion builder against the scene's demo nodes.
- [ ] Selecting a different composition type while one is already playing stops the current one and starts the newly selected one fresh.
- [ ] The duration badge shows the currently selected composition's reported duration kind, and its seconds value when the kind is Fixed.
- [ ] Opening the example scene and running it: each of the six composition types visibly animates its own state cards from waiting through playing to completed.
- [ ] Test: selecting each of the six composition types in turn completes without error and leaves every state card in the completed state.

#### Not this story
- No scrubbing/seeking, speed control, reduced-motion toggle, or easing-curve/direction picker (`ux-flow.md` "Not this scene yet").
- No navigation to or from other example scenes — this phase ships exactly one (`ux-flow.md`).
- Race and Conditional's duration-badge reading follows whatever story-4/story-5 implemented (including Race's flagged, unconfirmed duration rule) — this story doesn't resolve that, only displays it.

#### Notes
Depends on story-7 (theme, `StateCard`, `PlaybackControls`, and the Sequence demo already wired) and story-6 (the `Motion` builder). This is the phase's integration-owning story — it exercises the full end-to-end path (open scene → select each type → watch it complete), not just the slice this story adds.

#### Implementation Reference
- **UX:** `ux-flow.md` §Composition Example Scene — selector actions and "What happens on action" (rebuild + play on selection, cancel on restart).
- **Design:** `design-brief.md` §Component guide "Composition-type selector" (segment styling); §Screen composition (badge placement, right-aligned above the card row).
- **Build:** each of the six demo compositions built via `Motion` builder factories (story-6), using this scene's own demo nodes; reuse the theme/`StateCard`/`PlaybackControls` wiring from story-7, don't duplicate it.
- **Data:** duration badge text reads `AnimaDuration.kind` + `.seconds` (story-0) — `tech-spec.md` §Data model `AnimaDuration` row.
- **Boundaries:** the six demo composition definitions (which nodes, which template motions per type) live in `composition_playground.gd`'s own script, not in the shared components.
- **Testing:** a GUT test driving the scene through all six selector choices — `project-rules.md` §Testing; place under `tests/` alongside the other integration tests.
- **Do not:** add scrub/speed/reduced-motion/easing controls; add a second example scene.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
