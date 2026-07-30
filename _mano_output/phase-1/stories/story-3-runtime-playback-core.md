### STORY-3: Runtime playback core

#### What and why
A Godot developer wants to actually run a motion against a node — call one method, get something back they can await, pause, resume, or cancel — without wiring up a Tween or registering anything in their project settings first. This story makes a property motion actually play.

#### Done when
- [ ] Playing a property motion on a node, in a fresh scene with no autoload configured and no prior setup call, changes the target property to its end value by the time the motion completes.
- [ ] Playing a second motion on a node that already has one running starts an independent playback — the first one keeps running unaffected.
- [ ] Pausing a playback mid-motion freezes the animated property in place.
- [ ] Resuming a paused playback continues the motion from where it paused, still reaching the same end value.
- [ ] Cancelling a playback mid-motion stops the property from changing further, and its completion is not reported as successful.
- [ ] Test: a unit test plays a property motion on a test node across simulated frames and asserts the property reaches its end value; a second test exercises pause, resume, and cancel.

#### Not this story
- No Sequence or Parallel composition yet — this plays a single motion only; composition is the next two stories.
- No per-property conflict detection between overlapping playbacks — deliberately unguarded this phase (see Notes).
- No reverse, seek, or runtime speed controls — only pause, resume, and cancel ship this phase.

#### Notes
Two motions targeting the same node property at the same time are not guarded against — whichever motion writes the property last within a frame wins, per `tech-spec.md` §Key technical decisions. No dedicated AC for this; per-property ownership tracking is a separate, deferred backlog item.

Depends on: story-0, story-2.

#### Implementation Reference
- **Build:** `AnimaRuntime` (lazy, no autoload), the relational scheduler, the central per-frame evaluation loop, the `Anima.play(...)` entry point returning a playback object with pause/resume/cancel and a `finished` signal
- **Contract:** `tech-spec.md` §Data model (`AnimaRuntime`, `AnimaPlayback` rows) — states, signal
- **Rules:** `project-rules.md` §Architecture — entry point registered via `class_name`, not autoload; no references into the legacy addon
- **Test:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
