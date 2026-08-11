### STORY-7: Pivot moves to AnimaPivot.Kind

#### What and why
A developer setting a motion's pivot currently writes `.with_pivot(AnimaPropertyMotion.Pivot.CENTER)` — naming an unrelated motion class to reach an enum value. Moving the enum to its own `AnimaPivot.Kind`, mirroring how `AnimaEase.Kind` already reads, makes the name consistent with every other typed enum in the API.

#### Done when
- [ ] `.with_pivot(AnimaPivot.Kind.CENTER)` resolves to the same pivot behaviour `AnimaPropertyMotion.Pivot.CENTER` produced before this change
- [ ] Every pivot value previously under `AnimaPropertyMotion.Pivot` (`NONE`, `TOP_LEFT`, `TOP_CENTER`, `TOP_RIGHT`, `CENTER_LEFT`, `CENTER`, `CENTER_RIGHT`, `BOTTOM_LEFT`, `BOTTOM_CENTER`, `BOTTOM_RIGHT`) is available under `AnimaPivot.Kind` with the same name
- [ ] A keyframe stop's pivot value and a keyframe motion's default pivot both use the same `AnimaPivot.Kind` type as `AnimaPropertyMotion.pivot`
- [ ] Test: a motion authored with the old `AnimaPropertyMotion.Pivot` value either still resolves to the correct pivot behaviour, or fails validation with a message naming the outdated type

#### Not this story
- Changing pivot's resolution timing, anchor math, or which target classes support it — only the type's name/location changes

#### Notes
**Inferred design decision, confirm before implementing:** `AnimaPivot` is a new lightweight, non-`Resource` helper class living under `motion/resources/` (the same kind of helper `AnimaEase`/`Motion` already are per `project-rules.md §Folder Structure`), holding only `enum Kind` with the values listed above. If a different shape is intended (e.g. `AnimaPivot` as a full `Resource`, or keeping the enum nested elsewhere), update this story before implementing.

#### Implementation Reference
- **Build:** new `AnimaPivot` class holding `enum Kind` with the same values `tech-spec.md §Motion pivot control`'s `Pivot` enum currently lists; `AnimaPropertyMotion.pivot`, `AnimaKeyframeMotion.default_pivot`, and `AnimaKeyframeStop.pivot` (`tech-spec.md §Data model`) all change type from `AnimaPropertyMotion.Pivot` to `AnimaPivot.Kind`
- **Files:** `addons/anima/motion/resources/anima_pivot.gd` (new); `addons/anima/motion/resources/anima_property_motion.gd`; `addons/anima/motion/resources/anima_keyframe_motion.gd`; `addons/anima/motion/resources/anima_keyframe_stop.gd`
- **Rules:** `project-rules.md §Naming` — `class_name` PascalCase, `Anima`-prefixed, file name mirrors class name in snake_case; `project-rules.md §Testing` — GUT unit test on `AnimaPivot`/`AnimaPropertyMotion`; `project-rules.md §Documentation` — add the `##` doc comment for `AnimaPivot` and its `Kind` values
- **Do not:** do not change pivot's resolution timing or anchor math (`tech-spec.md §Motion pivot control`) — this story only moves the type

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
