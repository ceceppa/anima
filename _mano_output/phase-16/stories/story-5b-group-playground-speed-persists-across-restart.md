### STORY-5b: Group playground's selected speed survives restart

#### What and why
Picking a speed multiplier in the group playground, then switching playback mode or ordering, silently drops back to 1x — `restart()` builds a brand-new playback with no speed applied, discarding whatever the speed selector last chose. A visitor exploring the playground (pick a speed, then try a different ordering) sees the multiplier "stop working" the moment they touch anything else.

#### Done when
- [ ] Selecting a speed, then selecting a different playback mode or ordering, keeps the previously selected speed applied to the new playback that starts.
- [ ] Restarting via the restart control (not a mode/order change) also keeps the currently selected speed, not just mode/order changes.
- [ ] Selecting a new speed while a playback is already running still applies immediately, unchanged from today.
- [ ] Test: after picking a non-default speed and then triggering `restart()` (directly, or via a mode/order selection), the new `active_playback.speed_scale` still equals the selected speed.

#### Not this story
- Any other playground (`Anima.on()`'s or `Anima.grid()`'s) — even if they share the same pattern, this story only fixes the group motion playground the user actually hit.
- Any change to `AnimaPlayback.speed_scale`, `AnimaGroupMotionFactory`, or `AnimaGroupPlayback` themselves — the underlying speed-scale mechanism is already correct and already tested (`tests/Anima.integration.group-playback.test.gd`).

#### Implementation Reference
- **Build:** track the currently selected speed in a scene-level variable, set by the existing `speed_selected` handler; apply it to the freshly created playback inside `restart()`, right after `active_playback = Anima.play(_group, self)`
- **Files:** `examples/playground/group_motion_playground.gd` (`restart()`, the `speed_selected` connection in `_ready()`); `tests/Anima.integration.group-motion-playground.test.gd`
- **Rules:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
