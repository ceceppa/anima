### STORY-12b: Showcase remaining convenience families

#### What and why
A developer browsing the convenience playground today only sees five of the twelve `Anima.on()` families the addon actually ships — Move By, Scale, Rotation, Opacity, and Colour. The rest (Position, Position X, Position Y, Scale By, Rotate By, Size, and the generic Property escape hatch) are real, shipped API with no example to see them work. Showing every family the addon supports for a 2D Card target lets a developer evaluating `Anima.on()` discover the full surface in one place instead of reading source.

#### Done when
- [ ] The motion-family selector lists all twelve families valid for a 2D `Control` target: Position, Position X, Position Y, Move By, Scale, Scale By, Rotation, Rotate By, Opacity, Colour, Size, and Property.
- [ ] Choosing any of the seven newly-added families (Position, Position X, Position Y, Scale By, Rotate By, Size, Property) updates the shown example line to that family's `Anima.on(card)` call and replays a visible Card motion demonstrating it.
- [ ] Restart and reverse replay a newly-added family's selected motion the same recorded-run way they already do for the five existing families.
- [ ] Test: selecting each of the seven newly-added families produces a visible Card run, and replay controls return it through that family's actually recorded run.

#### Not this story
- `.position_z()` — `tech-spec.md §Convenience method interface` restricts it to `Node3D` targets; this playground's Card is a 2D `Control`, so there is no target to demonstrate it against.
- New modifiers (`.from()`, `.relative()`, `.then()`/`.with()` composition) beyond what the existing families already demonstrate.
- Any change to the Grid playground, the selector components themselves, or the shared theme.

#### Notes
The selector already wraps into multiple rows when it has more items than fit one line (`selector_dock.gd`'s `HFlowContainer`-based layout, established when the Grid playground's Formula selector needed the same thing) — going from five items to twelve needs no new UI work.

For the Property family's demo, pick any Card/CanvasItem property not already covered by a named family (e.g. something other than position, scale, rotation, modulate) so the escape hatch reads as genuinely generic rather than a duplicate of an existing family — the exact property is a demo-content choice, not a spec-owned value.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd`; `examples/playground/convenience_motion_playground.tscn`; `tests/Anima.integration.convenience-playground.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Convenience method interface` — exact method names, inputs/defaults, and canonical property mapping for every family, including the `Node3D`-only restriction on `.position_z()`
- **UX:** `_mano_output/ux-flow.md §Convenience Motion Example Scene` — "a selector for the supported convenience-motion families"
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
