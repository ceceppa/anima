### [STORY-2]: Derive group schedules

#### What and why
Animation authors can choose a group’s distribution and starting point without calculating timestamps. The resulting waves are repeatable, including centred, index-origin, and seeded-random groups.

#### Done when
- [ ] A sequential group starts the next visible item only after the preceding item finishes; a parallel group starts every valid item together.
- [ ] A staggered group supports fixed-interval and total-duration spreading, and items in the same wave start together.
- [ ] Forward, reverse, centred, edge, odd, even, random, grid, and index-origin choices produce the described visible sequence; an omitted origin starts from First.
- [ ] A seeded random group produces the same visible sequence when replayed with the same seed.
- [ ] The API reference page for `AnimaGroupOrder` explains each ordering choice and origin.
- [ ] Test: fixed input collections cover parity, even-centre waves, index-distance waves, reverse distribution, and repeated seeded random playback.

#### Not this story
- Running item motions or reacting to lifecycle changes.
- A legacy group-type API.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_group_order.gd`; `addons/anima/motion/runtime/anima_group_scheduler.gd`
- **Docs:** `docs/content/docs/anima/anima-group-order.md`
- **Tests:** `tests/AnimaGroupOrder.test.gd`; `tests/AnimaGroupScheduler.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model`, `§Group animation semantics`, and `§Product principle constraints`
- **Rules:** `_mano_output/project-rules.md §Naming`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; derive one schedule per execution and add `##` comments for public declarations.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
