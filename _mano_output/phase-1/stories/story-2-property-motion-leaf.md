### STORY-2: Property motion leaf type

#### What and why
A Godot developer wants to animate one property on a node — position, modulate, scale, anything settable — without writing a Tween by hand. This story gives them the one leaf type Phase 1 ships: a motion that animates a single property from one value to another over a fixed duration, using the curves from the previous story.

#### Done when
- [ ] A property motion can be built by naming a target property, an end value, and a duration.
- [ ] Validating a property motion with no target property reports an error; validating one with a target property, an end value, and a duration reports no errors.
- [ ] A property motion built without an explicit easing curve uses linear interpolation by default.
- [ ] Test: a unit test constructs property motions with and without required fields and asserts validation succeeds or fails accordingly, and asserts the default easing kind is linear when none is given.

#### Not this story
- No leaf types beyond Property motion — keyframe, native-Animation reference, signal wait, delay, callback, audio, shader-parameter, layout, shared-element, and nested-motion-reference leaves are deferred.
- No actual playback on a node yet — the runtime that executes this leaf is the next story.

#### Notes
A property motion built without an explicit start value reads the target node's current value when it actually plays — that behaviour is runtime behaviour, verified once the runtime exists (story-3), not here.

#### Implementation Reference
- **Build:** `AnimaPropertyMotion` leaf, extends `AnimaMotion`
- **Data:** `tech-spec.md` §Data model (`AnimaPropertyMotion` row) — fields, default ease
- **Rules:** `project-rules.md` §Patterns — implement `estimate_duration()` / `create_runtime()` / `validate()` explicitly, no silent no-op defaults
- **Test:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
