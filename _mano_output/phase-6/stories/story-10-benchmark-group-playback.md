### [STORY-10]: Benchmark group playback

#### What and why
Addon maintainers can measure group scheduling and playback against a fixed large collection before a regression reaches authors. The permanent benchmark makes performance changes visible in the project’s normal test suite.

#### Done when
- [ ] A repeatable benchmark runs group resolution, scheduling, and playback against a fixed large target collection and reports the measured duration.
- [ ] The benchmark covers sequential, parallel, and staggered playback without replacing the project’s permanent tests.
- [ ] Test: the benchmark fixture completes each covered playback mode and records its duration in the test output.

#### Not this story
- A performance target or device-specific certification.
- Runtime acceleration outside the established addon architecture.

#### Implementation Reference
- **Files:** `tests/Anima.integration.group-benchmark.test.gd`
- **Contract:** `_mano_output/phase-6/phase-brief.md §Phase Scope`; `_mano_output/tech-spec.md §Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Testing`; retain the benchmark as a permanent GUT test.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
