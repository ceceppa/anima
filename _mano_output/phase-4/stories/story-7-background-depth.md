### STORY-7: Background depth behind the cards

#### What and why
Whoever looks at the stage while cards animate sees a soft glow of colour behind them instead of a completely flat dark field, giving the stage a sense of depth without adding visual noise that competes with the cards.

#### Done when
- [ ] The stage shows a soft, centred colour glow behind the card row, clearly less prominent than any individual card's own glow
- [ ] The glow stays within the stage's rounded corners — it does not extend past the stage's edge
- [ ] The glow's position and appearance stay the same regardless of which composition type is selected

#### Not this story
- Any grid/dot texture alternative — `design-brief.md` already resolved this to a radial gradient only; do not add a second treatment.
- The stage container's own border/shadow — story-2.

#### Notes
Depends on story-2 (the stage container exists to clip the glow to).

#### Implementation Reference
- **Design:** `design-brief.md` §Component guide "Background depth treatment" — radial gradient, colour/alpha, clipped to the stage's rounded corners
- **Files:** `examples/composition_playground.tscn` / `examples/composition_playground.gd` — add the gradient layer inside the stage, behind the card row
- **Do not:** no dot/grid texture (`design-brief.md` picked the radial gradient only)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
