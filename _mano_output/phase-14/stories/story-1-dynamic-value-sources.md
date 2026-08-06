### STORY-1: Dynamic values resolve against live node state

#### What and why
A developer animating a Godot scene with Anima can point a motion's start or end value at a node's own real property instead of typing a hardcoded number that goes stale the moment the scene's layout changes. Today every `from`/`to` value is a fixed literal chosen at authoring time; this story lets that value be read live from the animated node itself, from another named node, or from data the developer supplies before playback starts.

#### Done when
- [ ] A property motion's value reads the animated node's own property and plays from/to that node's real current value at the moment playback starts, not a value baked in when the motion was authored.
- [ ] A property motion's value reads a different, explicitly named node's property and resolves to that other node's real value when playback starts.
  - [ ] Test: two motions using the same dynamic-value definition against two different nodes each resolve to their own node's value, not a shared one.
- [ ] A value naming a node path that does not exist when playback starts fails with a reported error instead of silently animating to an unresolved value.
- [ ] A value reading from arbitrary data supplied to the playback before it starts resolves to whatever was stored there under the matching key.
- [ ] The generated API reference includes a page for the new dynamic-value type, documenting its resolve contract and every way to construct one.

#### Not this story
- Combining two dynamic values together, or any arithmetic on a resolved value — story-2.
- Using a dynamic value inside a keyframe — story-3.
- A dynamic value resolving independently per item inside a group or grid, including the "root" source's group-container meaning — story-4.
- The `Anima.grid()` one-line shorthand — story-5.
- Configurable resolution timing (resolving at parent-playback-start or continuously) — not this phase, matching v1's own once-at-start behaviour.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_value.gd` (new — `AnimaValue`, `Kind` enum, static factories `constant`/`target`/`node`/`root`/`context`, `resolve()`); `addons/anima/motion/runtime/anima_value_context.gd` (new — `AnimaValueContext`); wire into the property-motion runtime instance under `addons/anima/motion/runtime/` (resolve `from_value`/`to_value` when `is AnimaValue`, per `tech-spec.md` §Dynamic values "Resolution timing"); `addons/anima/motion/runtime/anima_playback.gd` gains `context_data: Dictionary`
- **Contract:** `tech-spec.md` §Dynamic values, §Dynamic value interface — exact `AnimaValue.constant/target/node/root/context` signatures, resolution timing, and the `create_runtime(context = null)` signature extension (context stays `null` in this story; story-4 is the first caller that populates one)
- **Rules:** `project-rules.md` §Folder Structure (`AnimaValue` is a construction-time Resource → `motion/resources/`; `AnimaValueContext` is transient runtime state, same category as `AnimaExecutionRecord` → `motion/runtime/`); §Architecture ("Resources hold authored config only" — do not cache a resolved context back onto the `AnimaValue` resource itself); §Node Liveness (a missing `AnimaValue.node()` target is a resolve-time validation failure, not a null-check-then-continue)
- **Tests:** `tests/AnimaValue.test.gd` (new, unit — `resolve()` for `CONSTANT`/`TARGET`/`NODE`/`ROOT`/`CONTEXT`, missing-node failure); `tests/Anima.integration.dynamic-values.test.gd` (new, integration — `Anima.play()` with a property motion whose `from`/`to` is an `AnimaValue`)
- **Do not:** implement arithmetic chain methods, keyframe integration, or group/grid per-item context in this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
