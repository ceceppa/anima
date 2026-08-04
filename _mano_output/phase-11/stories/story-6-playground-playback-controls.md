### STORY-6: Playground playback controls demo

#### What and why
A developer evaluating Anima by running one of its example playgrounds could, until now, only restart or reverse a motion — there was no way to see `complete()`, `revert()`, a speed change, or the reduced-motion switch actually working without writing their own script. This story wires the four new capabilities into the shared control bar every playground already uses, so a developer can see and try all of them live in any of the existing example scenes.

#### Done when
- [ ] Every existing playground scene (Composition, Group Motion, Convenience, Grid, and 3D Motion) shows two additional circular buttons — Complete and Revert — alongside the existing Restart and Reverse buttons, laid out and styled per `design-brief.md` §Component guide → Playback controls
- [ ] Pressing Complete on a running motion snaps the current card (or 3D card) to its end state immediately
- [ ] Pressing Revert on a running motion returns the current card (or 3D card) to its starting state immediately
- [ ] Every playground scene also shows the new speed control (0.5×/1×/2×) and the reduced-motion toggle from `design-brief.md`
- [ ] Choosing 0.5× or 2× visibly changes how fast the current motion plays; choosing 1× returns it to normal pace
- [ ] Turning the reduced-motion toggle on and restarting a motion that has a reduced-motion speed set plays it at that pace instead of its normal one
- [ ] End-to-end: in one playground, a developer can restart a motion, watch it partway, reverse it, then complete it, then revert it, then change its speed and toggle reduced motion — all without leaving that one scene
- [ ] Test: a GUT unit test on the shared playback-controls component asserts each new button/control invokes the matching `AnimaPlayback`/`Anima` call

#### Not this story
- Real Complete/Revert icon artwork — ships with placeholder glyphs (✓ / ↺) the same way Restart/Reverse originally did before their own artwork arrived; swapping in real SVGs is a follow-up, not blocked by this story
- Progress-based seeking or a scrub timeline — out of phase scope
- Any change to the underlying `complete()`/`revert()`/speed/reduced-motion runtime behaviour — that's stories 1, 3, and 5; this story only wires the existing shared UI to them

#### Notes
Depends on stories 1, 3, and 5 (the runtime methods/fields this story wires up) being implemented first. Because `PlaybackControls` is one shared component, this single story's change reaches every playground scene at once — see the design brief's ⚠ Verify on that reach.

#### Implementation Reference
- **Files:** `examples/playground/shared/components/playback_controls.gd`/`.tscn` (new Complete/Revert buttons, Speed `SelectorDock`, `ToggleSwitch`); new `examples/playground/shared/components/toggle_switch.gd`/`.tscn` per `design-brief.md`'s `ToggleSwitch` spec
- **Design:** `_mano_output/design-brief.md` §Component guide → Playback controls, Speed control, Reduced-motion toggle, ToggleSwitch; §Screen composition — phase-11 — Motion Playback Controls; preview at `_mano_output/phase-11/design-preview.html`
- **Contract:** `tech-spec.md` §Playback interface for the exact `complete()`/`revert()` signatures and the `forward_speed`/`reverse_speed`/`Anima.reduced_motion`/`reduced_motion_speed` fields this story reads and writes
- **Rules:** Signal Connections — `project-rules.md` §Signal Connections (new buttons already exist in each `.tscn` at edit time, so connect them via the editor, not `.connect()` in code); Naming — component scripts stay plain-named (`PlaybackControls`, `ToggleSwitch`), no `Anima` prefix, per `project-rules.md` §Naming; Example Scenes — reuse the one shared component across every playground rather than duplicating it, per `project-rules.md` §Example Scenes; Testing — `project-rules.md` §Testing
- **Do not:** duplicate the control bar per playground scene — one shared `PlaybackControls` change reaches all of them

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
