### [STORY-8]: Respect reduced motion

#### What and why
People who use reduced motion can still follow a group animation’s visibility and completion without waiting through its full stagger. This preserves the group’s outcome while reducing its visual travel.

#### Done when
- [ ] With reduced motion enabled, every valid target becomes visible and the group reaches its completion outcome without the normal staggered presentation.
- [ ] Completion and cancellation callbacks occur once for the group in reduced-motion playback.
- [ ] Test: the same group finishes with all valid targets visible when reduced motion is enabled and when it is disabled.

#### Not this story
- A reduced-motion toggle in the example or Composer.
- Layout-transition behavior.

#### Implementation Reference
- **Files:** update `addons/anima/motion/runtime/anima_group_playback.gd`
- **Tests:** `tests/Anima.integration.group-reduced-motion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Testing`; preserve the derived group completion outcome.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
