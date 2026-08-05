### STORY-6a: Spring demo shows no visible oscillation

#### What and why
A developer evaluating Anima opens the convenience motion playground, selects the new Spring family added this phase, and expects to see the card overshoot its target and settle back the way a spring visibly behaves — but today it just glides to the target with no bounce, indistinguishable from any other eased family already in the playground. This undermines the exact demo Phase 12 added to prove springs actually work visually (Phase 11's review flagged that springs had test coverage but no visual demo; this bug means the gap is still effectively open).

#### Done when
- [ ] Selecting the Spring family in the convenience motion playground plays a motion that visibly passes its target value and settles back at least once before coming to rest, distinguishing it from a plain eased motion
- [ ] Test: an automated check confirms the Spring family's motion value overshoots past its target before settling at it

#### Not this story
- Any change to spring simulation itself (`AnimaEase.evaluate()`, `_advance_spring()`) — only the demo's own parameters or property choice are in scope, unless investigation shows the simulation itself never oscillates for any parameter combination, which would then need to route back through `mano spec`
- A general spring-tuning UI or exposing spring parameters as playground controls — out of scope, same as every other family

#### Notes
Reported against story-5's Spring family (`_build_spring_motion()`), already shipped. Bug story per the mid-build addition flow — sub-numbered off story-6, the most recently completed story at report time, not off story-5 whose behaviour it actually concerns.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd` (`_build_spring_motion()`) — current parameters: `spring_response = 0.3`, `spring_bounce = 0.15`
- **Contract:** `addons/anima/motion/resources/anima_ease.gd` — `spring_bounce` feeds `damping_ratio = 1.0 - spring_bounce`; a damping ratio close to `1.0` is at or near critical damping, which produces little or no overshoot by definition
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
