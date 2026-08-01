### [STORY-3]: Run group playback

#### What and why
Animation authors can play a group as independent item animations, then pause, resume, change speed, cancel, or reverse that exact run. A changing scene does not turn one item’s lifecycle into an unexplained failure for the rest.

#### Done when
- [ ] Playing a group starts each resolved item according to its selected schedule, even when item durations differ.
- [ ] Pausing, resuming, changing speed, and cancelling a running group affect its active items as one playback.
- [ ] Reversing a completed or active group reuses its recorded target sequence; a seeded random group does not reshuffle.
- [ ] When a target leaves the scene during playback, the remaining visible items follow the selected completion and invalid-target policies.
- [ ] The API reference pages for `AnimaGroupPlayback` and `AnimaExecutionRecord` explain interruption and reversal behavior.
- [ ] Test: public group playback covers pause, cancel, speed change, target departure, and reverse replay through `Anima.play(...)`.

#### Not this story
- Group builder shortcuts or Motion Composer controls.
- Native Animation compilation.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_group_playback.gd`; `addons/anima/motion/runtime/anima_execution_record.gd`; update `addons/anima/motion/runtime/anima_playback.gd`
- **Docs:** `docs/content/docs/anima/anima-group-playback.md`; `docs/content/docs/anima/anima-execution-record.md`
- **Tests:** `tests/AnimaGroupPlayback.test.gd`; `tests/AnimaExecutionRecord.test.gd`; `tests/Anima.integration.group-playback.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model` and `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Architecture`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; execution state stays runtime-only and every public declaration receives a `##` comment.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
