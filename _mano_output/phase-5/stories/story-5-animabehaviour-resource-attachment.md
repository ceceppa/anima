### STORY-5: AnimaBehaviour resource + attachment

#### What and why
Whoever wants to attach a reusable configuration resource to an ordinary node — without subclassing it — can create an `AnimaBehaviour` and attach it via `Anima.attach_behaviour()`, then find it again later via `Anima.get_behaviour()`, without tracking the reference themselves.

#### Done when
- [ ] Creating an `AnimaBehaviour` resource and attaching it to a node via `Anima.attach_behaviour(node, behaviour)` does not change that node's class or require a new node type
- [ ] Calling `Anima.get_behaviour(node)` after attaching returns the exact same `AnimaBehaviour` instance that was attached
- [ ] Calling `Anima.get_behaviour(node)` on a node with nothing attached returns `null` instead of erroring
- [ ] A scene containing a node with an attached `AnimaBehaviour`, packed and instantiated again, still returns that behaviour from `Anima.get_behaviour(node)` on the new instance
- [ ] Test: attaching an `AnimaBehaviour` to a node also makes that node discoverable via the private group used for behaviour discovery

#### Not this story
- Any Inspector UI, undo/redo, inheritance/override resolution, runtime-state separation (`AnimaNodeInstance`), or working state-binding behaviour — all separate, later backlog items.
- Anything that reads `motion_in`/`play_in_on_ready`/etc. to actually play a motion automatically — the resource is configuration only this phase; no runtime consumer exists yet.

#### Implementation Reference
- **Data:** `tech-spec.md` §Data model `AnimaBehaviour` row — full field list and defaults
- **Files:** `addons/anima/motion/resources/anima_behaviour.gd` (new); `Anima.attach_behaviour(node: Node, behaviour: AnimaBehaviour) -> void` and `Anima.get_behaviour(node: Node) -> AnimaBehaviour` added to `addons/anima/motion/runtime/anima.gd`
- **Test files:** `tests/AnimaBehaviour.test.gd` (new); `tests/Anima.integration.behaviour_storage.test.gd` (new — the pack/instantiate persistence check needs a real `PackedScene.pack()`/`instantiate()` round trip, not just an in-memory attach-then-read)
- **Do not:** no node metadata key or group name other than `"_anima_behaviour"` / `"_anima_enabled"` (`tech-spec.md` §Data model `AnimaBehaviour` row); no hidden child node or new node subclass for storage

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
