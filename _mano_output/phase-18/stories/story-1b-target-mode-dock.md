### story-1b: Target-mode dock and label stage

#### What and why
Story-1's stage always showed the shared `Card` component, with the light_speed presets' `Sprite2D` swapped in and out silently — there was no way to see or choose which target type you were looking at. This story adds a visible target-mode control and replaces `Card` with a plain "anima" label as the Control-family target, so a developer can compare both target types side by side.

#### Done when
- [ ] A target-mode control (`Both` / `Control` / `Sprite2D`) sits at the top of the stage, `Both` selected by default.
- [ ] With `Both` selected, the stage splits in two: a plain label reading "anima" on the left (the target every preset except `lightspeed` plays on), the existing sprite placeholder on the right (the target `lightspeed` presets play on).
- [ ] Selecting `Control` shows only the label, full width; selecting `Sprite2D` shows only the sprite, full width.
- [ ] Changing the target-mode never changes which target the currently selected preset actually animates on — it only changes which stage half(s) are visible.
- [ ] The separate stage title text is removed — the grid's own selected button already names the current preset.

#### Not this story
- No change to which presets target the label vs. the sprite (still exactly the 4 `lightspeed` presets on `Sprite2D`, everything else on the label).
- No renaming of the `Card` shared component itself — it's simply no longer used by this scene; other playgrounds keep using it unchanged.

#### Implementation Reference
- **Build:** target-mode control is the existing horizontal `SelectorDock` reused a second time in this scene, alongside a plain `Label` and a `Sprite2D` laid out side by side in an `HBoxContainer`, each half's visibility driven only by the target-mode selection — `design-brief.md` §Component guide ("Target-mode dock") and §Screen composition — phase-18.
- **Flow:** exact interaction and default state — `ux-flow.md` §Animation Catalog Playground.
- **Do not:** no new playback control; the target-mode dock is purely a visibility switch, never a routing decision for which node a preset plays on.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
