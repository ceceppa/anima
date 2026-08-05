### STORY-6a: Fix Complete/Revert/Reduced-motion controls in the playground

#### What and why
A developer trying the Complete/Revert buttons or the reduced-motion toggle story 6 added currently gets none of the three actually working: Complete and Revert just stop the animation wherever it happens to be — the same as a plain stop — instead of snapping to the end or start value, and toggling reduced motion produces no visible change at all. This defeats the whole point of story 6's demo: none of these capabilities can actually be seen working.

#### Done when
- [ ] Pressing Complete on a running motion in any playground snaps it to its authored end value immediately, matching `AnimaPlayback.complete()`'s documented behaviour — not merely stopping wherever it was
- [ ] Pressing Revert on a running motion in any playground snaps it back to its pre-animation starting value immediately, matching `AnimaPlayback.revert()`'s documented behaviour
- [ ] Pressing Complete or Revert while nothing is currently playing has no effect — confirms the fix doesn't regress the already-correct "no active playback" case
- [ ] Turning "Reduced motion" on, then restarting a motion that has a reduced-motion speed configured, visibly plays it at that different pace; turning it back off restores the normal pace
- [ ] Test: at least one GUT integration test per fix that exercises the real chain — presses the actual `PlaybackControls` button (or toggles the switch) inside a real playground scene and asserts the resulting `AnimaPlayback`/`Anima` state, not just that `PlaybackControls` itself emits its signal

#### Not this story
- Any new visual or design change to the controls — story 6's design stands; only the underlying wiring is being fixed
- Any playground-specific demo content beyond what story 6 already added

#### Notes
Reported by manual testing in the Godot editor after story 6 shipped. Story 6's own tests only checked that `PlaybackControls` emits its signals when its buttons are pressed — none exercised the full chain through to the actual `AnimaPlayback`/`Anima` call in a real playground scene, which is the coverage gap that let this ship; the new integration tests above close it.

#### Implementation Reference
- **Files:** `examples/playground/shared/components/playback_controls.gd`; `examples/playground/shared/components/toggle_switch.gd`; each of `examples/playground/composition_playground.gd`, `group_motion_playground.gd`, `convenience_motion_playground.gd`, `grid_motion_playground.gd`, `3d_motion_playground.gd`
- **Contract:** `tech-spec.md` §Playback lifecycle: cancel, complete, revert, reverse (exact `complete()`/`revert()` behaviour) and §Speed, direction, and reduced motion (the reduced-motion override's three-way resolution) — the real behaviour these controls must trigger
- **Do not:** assume the defect is in only one file — verify the full signal chain from button press through to the underlying `AnimaPlayback`/`Anima` call, since the symptom (behaving like a plain stop; no visible change for reduced motion) could originate at any link in that chain

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
