### STORY-4: Anima.of node proxy

#### What and why
Whoever wants to animate a single node directly — without building an `AnimaMotion` resource by hand — can write `Anima.of($Node).to(...)` (or `.transition_to()`, `.enter()`, `.exit()`) and have it play immediately, the same way `Anima.play()` would.

#### Done when
- [ ] Calling `Anima.of(node).to(property, value)` animates that property on that node and completes the same way `Anima.play()` playing an equivalent `AnimaPropertyMotion` would
- [ ] Calling `Anima.of(node).transition_to({...})` with more than one property animates all of them together, completing when the slowest one does
- [ ] Calling `Anima.of(node).enter()` on a node with no `AnimaBehaviour` attached fades the node in (`modulate:a` from 0 to 1) using the proxy's built-in default duration and ease
- [ ] Calling `Anima.of(node).exit()` on the same kind of node fades it out (`modulate:a` toward 0) the same way, in reverse
- [ ] `to()` and `transition_to()` accept an optional duration and ease that override the proxy's defaults when provided

#### Not this story
- Reading `motion_in`/`motion_out` from an attached `AnimaBehaviour` instead of the built-in fallback motion — a separate, later backlog item ("AnimaBehaviour-bound Anima.of proxy usage").
- Any state-binding (hover/pressed/etc.) surface — a separate, later item.

#### Notes
Independent of stories 1–3 and 5 — `Anima.of()` only depends on `Anima.play()`/`AnimaPropertyMotion`/`AnimaParallel`, all already shipped.

#### Implementation Reference
- **Data:** `tech-spec.md` §Data model `AnimaNodeProxy` row — `DEFAULT_DURATION`/`DEFAULT_EASE` constants, method signatures
- **Files:** `addons/anima/motion/runtime/anima_node_proxy.gd` (new); `Anima.of(node: Node) -> AnimaNodeProxy` added to `addons/anima/motion/runtime/anima.gd`
- **Test files:** `tests/AnimaNodeProxy.test.gd` (new); `tests/Anima.integration.node_proxy.test.gd` (new — crosses `Anima.of`, `Anima.play`, `AnimaPropertyMotion`/`AnimaParallel` through the public `Anima.of` entry point, per `project-rules.md` §Testing)
- **Do not:** no reading of `AnimaBehaviour` fields this story, even when one happens to be attached to the node

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
