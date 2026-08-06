### STORY-2: Combine dynamic values arithmetically

#### What and why
A developer building a value from more than one live property — one node's width plus a margin read from another node, say — can chain that math directly onto the dynamic value itself instead of resolving each piece by hand and combining them in a separate script. This closes the exact gap the RPG showcase hit: a motion whose destination depends on more than one live number at once.

#### Done when
- [ ] A dynamic value combined arithmetically with a second dynamic value resolves to the mathematically combined result of both live values.
- [ ] A dynamic value combined with a plain fixed number resolves using that literal directly, without the literal needing to be wrapped as a dynamic value first.
- [ ] A dynamic value clamped between two bounds never resolves outside those bounds, even when the underlying live value would otherwise exceed them.
- [ ] A dynamic value computed through an author-supplied custom calculation resolves to whatever that calculation returns, covering math the built-in combinations don't express.
  - [ ] Test: the same base dynamic value combined two different ways (e.g. multiplied by two different numbers) produces two independent results — combining it once never changes what the original resolves to on its own.
- [ ] The generated API reference documents every arithmetic combination and the custom-calculation escape hatch alongside the sources documented in story-1.

#### Not this story
- Reading a dynamic value's own source (target/node/root/context) — story-1.
- Using a combined value inside a keyframe — story-3.
- Per-item resolution inside a group or grid — story-4.

#### Notes
The Test AC under "combined with a custom calculation" bullet verifies the immutable, wrap-don't-mutate design `tech-spec.md` §Dynamic values specifies — the concrete reason a reused base value doesn't leak state between two different expressions built from it.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_value.gd` (extend — arithmetic `Kind` values: `ADD`/`SUBTRACT`/`MULTIPLY`/`DIVIDE`/`NEGATIVE`/`ABSOLUTE`/`MINIMUM`/`MAXIMUM`/`CLAMP`/`MAP`/`COMPONENT`, plus `CALL`)
- **Contract:** `tech-spec.md` §Dynamic values ("Arithmetic composition", "Callable fallback"), §Dynamic value interface — exact chain-method signatures, the immutable "returns a new AnimaValue" contract, `.map()`'s linear-remap formula
- **Rules:** `project-rules.md` §Documentation (a doc comment for every new chain method and `Kind` value)
- **Tests:** `tests/AnimaValue.test.gd` (extend — arithmetic ops, clamp, map, call, immutability); `tests/Anima.integration.dynamic-values.test.gd` (extend — a real motion combining two dynamic values end-to-end)
- **Do not:** implement keyframe or group/grid integration in this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
