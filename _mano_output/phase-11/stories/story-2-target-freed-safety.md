### STORY-2: Target-freed playback safety

#### What and why
A developer who lets a played motion's target node get freed mid-animation — a UI element closing, an enemy dying — currently leaves that motion silently running against a dead reference forever, quietly wasting frame time it should have stopped using long ago. This story makes Anima notice and stop cleanly the moment that happens, so a developer never has to remember to manually cancel every playback whose target might disappear.

#### Done when
- [ ] Freeing a node that a motion is actively playing against stops that motion, with no runtime error printed
- [ ] After the target is freed, the stopped playback no longer appears among actively-advancing playbacks — it stops consuming per-frame work
- [ ] This safety behaviour applies the same way whether the playback was started through `Anima.play()`/`Anima.play_backwards()` or constructed directly
- [ ] Hiding a motion's target, reparenting it, or pausing the scene tree mid-playback does not stop the motion — hidden and reparented targets keep animating, and a paused scene tree simply stops advancing the motion until unpaused, confirming these stay unchanged by the new target-freed handling
- [ ] Test: a GUT integration test frees a playback's target mid-animation and asserts the playback stops and is no longer advanced; a companion test confirms hide/reparent/pause do not stop it

#### Not this story
- The "layout target removed" lifecycle case — layout transitions don't exist yet
- Per-property ownership release or signal disconnection on cancellation — see story-1's Not this story

#### Notes
This is the fix for the Phase 10 review's flagged leak (a discarded-but-uncancelled playback left running in `AnimaRuntime`). Shares `cancel()` with story-1 but has no field or behaviour dependency on it — can be built independently.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_playback.gd` (`_init()` connects `target.tree_exiting` to `cancel()`)
- **Contract:** `tech-spec.md` §Lifecycle-safe playback policies — the five already-correct defaults and the one new target-freed mechanism
- **Rules:** Testing — `project-rules.md` §Testing (integration test named `Anima.integration.*`, permanent, never disposable)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
