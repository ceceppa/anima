### STORY-7: RPG showcase icon pulse uses each icon's real scale

#### What and why
A developer capturing the Phase 13 RPG showcase for social media sees every inventory icon pulse relative to its own actual fitted size, instead of every icon snapping to one shared guessed scale regardless of how big it actually is on screen — the known, documented limitation Phase 13 shipped with while dynamic values didn't exist yet.

#### Done when
- [ ] Playing the showcase's Scene 1: two icons with different fitted sizes peak at different, size-proportional scales during the pulse, instead of both peaking at the same fixed scale.
- [ ] The pulse's fade and timing are otherwise unchanged from how Scene 1 already plays today.
- [ ] The showcase's known-limitation comment describing the shared-literal-scale workaround is removed, since the limitation it described no longer exists.
  - [ ] Test: running the full showcase sequence end-to-end (Scene 1 through Scene 4) still completes exactly as it does today, with Scene 1's icon pulse now scaling per icon.

#### Not this story
- Any change to Scene 2, 3, or 4's own content or timing.
- Adopting the `Anima.grid()` shorthand inside the showcase — out of scope per the phase brief; this story only replaces the pulse's scale values.

#### Notes
Depends on story-3 (dynamic values inside keyframes) and story-4 (per-item resolution in a grid's item motion) — the pulse is a keyframe motion used as a grid's shared item motion, so it needs both. This story is the phase's own end-to-end integration point: its Test AC is the one that exercises the full dynamic-value-in-keyframe-in-grid path together, not just each piece in isolation.

#### Implementation Reference
- **Files:** `examples/showcase/grid/inventory_grid.gd` (`_build_item_motion()` — replace the shared literal scale values with a dynamic value read from each icon's own current scale)
- **Contract:** `tech-spec.md` §Dynamic values — a keyframe step's value resolves per-item the same way any other group/grid item motion value does (story-4)
- **Tests:** `tests/Anima.integration.grid-showcase-inventory-hook.test.gd` (extend — replace the shared-literal-peak assertion with a per-icon, size-proportional one); `tests/Anima.integration.grid-showcase.test.gd` (existing full-sequence test already covers the regression AC)
- **Do not:** touch any asset-loading code — the existing icon-scanning exception to the ext_resource rule already covers this scene's assets

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
