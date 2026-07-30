### STORY-1: Shared example header component

#### What and why
Whoever opens the composition example scene sees a compact, branded header — an icon, a title, and a subtitle — sitting above the demo, instead of today's plain centred "Composition Example" text. The same header component is what every future Anima example scene will reuse, so it's built once here, not as a one-off label in this scene's script.

#### Done when
- [ ] Opening `composition_playground.tscn` shows a header row at the top of the scene with an icon, a title ("Composition"), and a subtitle ("Combine simple animations into expressive flows."), replacing the previous centred scene title
- [ ] The header stays visible, in the same position and size, no matter which composition type is currently selected
- [ ] Test: calling `set_title("X")` on the header displays "X"; calling `set_subtitle("Y")` displays "Y"
- [ ] Test: calling `set_counter("01 / 05")` shows that text; leaving it unset (or passing an empty string) hides the counter entirely

#### Not this story
- Applying the header component to any other example scene — only `composition_playground.tscn` exists today.
- The stage container below the header, the per-type title/description inside the stage, or the selector dock — separate stories.
- Designing new per-type icon assets — reuse whatever icon mechanism the composition-type selector already uses (see Implementation Reference).

#### Notes
No dependency on other Phase 4 stories — this is the first structural piece the later stories (stage, dock) sit below.

#### Implementation Reference
- **Files:** `examples/shared/components/example_header.tscn`, `examples/shared/components/example_header.gd`
- **Contract:** `project-rules.md` §Example Scenes — `ExampleHeader` (`set_title`, `set_subtitle`, `set_counter`). Also add an icon setter following the same naming pattern (e.g. `set_icon(icon: Texture2D)`) — the project-rules.md contract lists the text setters only; the icon setter is a trivial extension of the same shape, not a new design decision.
- **Design:** `design-brief.md` §Component guide "Shared example header", §Typography (header title/subtitle sizes), §Spacing scale (header padding), §Colour palette (`surface`, `border`, header shadow values)
- **Icons:** reuse whichever icon mechanism the existing composition-type selector already uses for its per-type icons (`design-brief.md` §Icon style) — do not introduce a new icon asset pipeline for this one header.
- **Test file:** `tests/ExampleHeader.test.gd` (new), per `project-rules.md` §Testing naming convention
- **Do not:** no inline `StyleBoxFlat` or colour literals in `composition_playground.gd` for the header — use `ExampleHeader` plus the shared theme

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
