### STORY-6b: Speed multiplier not applied to any convenience example

#### What and why
A developer trying the Speed control (0.5x/1x/2x, etc.) in the convenience motion playground selects a different speed expecting the currently showing family to visibly play faster or slower — but every family always plays at the same, unchanged pace no matter what speed is selected. This was first reported against the Spring family but confirmed to affect all fifteen families in this playground, not just spring.

#### Done when
- [ ] Selecting a non-1x speed in the convenience motion playground, then restarting (via the Restart button or by selecting a family), plays that family's motion at the selected pace, not always at the default pace
- [ ] The selected speed stays in effect across multiple restarts and family switches, until a different speed is explicitly picked
- [ ] Test: an integration test selects a non-1x speed, restarts, and asserts the resulting `AnimaPlayback`'s effective speed reflects the selection

#### Not this story
- Any change to how `speed_scale` composes with `forward_speed`/`reverse_speed` on `AnimaPlayback` — that composition already exists and is unaffected
- Any change to any other playground's speed handling — scoped to the convenience motion playground, this bug report's subject

#### Notes
Likely cause: the selected speed is applied only to whichever `AnimaPlayback` happens to be active at the moment of selection (`_controls.speed_selected` sets `_active_playback.speed_scale` directly), and is not preserved when `restart()` builds a fresh `AnimaPlayback` afterward — every restart silently resets to the default speed. Confirm during implementation rather than assuming; the fix must persist the last-selected speed across the family's own reference, wherever that turns out to live.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd` (`restart()`, `_controls.speed_selected` handler)
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — `AnimaPlayback.speed_scale`
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
