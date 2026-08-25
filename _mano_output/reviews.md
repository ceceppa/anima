# Phase Review — Anima

<!-- Always append new phase entries at the bottom of the file. Never insert between existing entries. -->
<!-- For follow-up fix work on an already-reviewed phase, append an ### Addendum subsection to the existing phase entry — do not create a new ## heading. -->

---

## Phase 14 Review — 2026-08-11

### Evidence

- **Status:** partial
- **Method:** Not recorded
- **Observed:** Several `Anima.on`/`Anima.grid` API calls behave unexpectedly or are missing when used directly in code (chaining, `with_ease`, delay/lifecycle hooks, pivot naming, `.play()`)

### Assumption results

| Assumption | Outcome | Evidence / consequence |
|-----------|---------|------------------------|
| Dynamic values resolve once, implicitly, at motion start. | confirmed | |
| Combining dynamic values arithmetically is distinct from reuse-on-reversal (deferred). | confirmed | |

### Backlog changes

- [bug] Anima.on() chain does not expose .play() — added
- [bug] Chained motions via .with() do not play correctly — added
- [refinement] Simplify pivot API naming — added
- [refinement] Anima.on missing with_delay — added
- [refinement] Anima.grid missing on_started/on_completed callbacks — added
- [refinement] Anima.grid missing with_delay — added
- [refinement] with_ease should accept AnimaEase.Kind directly on Anima.on — added
- [feature] Convenience fade_out on Anima.on — added
- [feature] Convenience fade_in on Anima.on — added

---

## Phase 15 Review — 2026-08-12

### Evidence

- **Status:** partial
- **Method:** Not recorded
- **Observed:** Not recorded — feedback described desired API shape rather than a described test/observation

### Assumption results

| Assumption | Outcome | Evidence / consequence |
|-----------|---------|------------------------|
| This phase fixes and completes the current `Anima.on`/`Anima.grid` builder signatures without adding the deferred `animation` name/tres keyword. | confirmed | |

### Backlog changes

- [refinement] play_with_delay() to delay the whole chain — added
- [refinement] Hide internal builder classes behind a non-public naming convention — added
- [feature] .wait(seconds) chain method for inline pauses — added

---

## Phase 16 Review — 2026-08-17

### Evidence

- **Level:** gathered
- **Tried:** Used `Anima.on`/`Anima.grid` with the new `.wait()` chaining in the Showcase; tested `Anima.group()` in the group motion playground
- **Result:** Everything worked as expected

### Phase checks

| Phase promise | Result | What happened |
|---|---|---|
| `Anima.group(%Container)...play()` animates every child of `%Container`; `Anima.group([$A, $B, $C])...play()` animates exactly those three nodes | passed | Tested in the group motion playground |
| Whole-chain `.with_delay()` on a composed `.then()`/`.with()` chain delays the start; both steps still play in original order | passed | Exercised in the Showcase |
| `.wait(1.0)` starts the next step 1s later; combined with the next step's own `with_delay(0.5)`, starts it 1.5s later | passed | Exercised in the Showcase |
| Autocomplete/class list for `Anima.*` no longer surfaces `AnimaParallel`/`AnimaSequence`/similar as equally-weighted public options | passed | confirmed |

### Decision

- **Choice:** The convenience API is solid enough to be used for real — stop treating it as a moving target and start building real scenes on top of it.
- **Why:** Exercised in the Showcase (`Anima.on`/`Anima.grid` with `.wait()`) and in the group motion playground (`Anima.group()`) — all worked as expected.

### Assumptions

| Assumption | Result | What showed this |
|-----------|---------|------------------------|
| A single `Anima.group()` factory covering both a container-Node target and an explicit-array target is sufficient — no separate factory or mode flag is needed for the two forms. | confirmed | |

### Backlog changes

- No new items. Existing follow-ups: [test] Layout transition GUIDE/Documentation and [test] Layout transition Tutorial.

---

## Phase 17 Review — 2026-08-17

### Validation

- **Result:** Automated tests cover all 99 ported presets (registry lookup by name and by asset, resolved keyframe/dynamic values, full-catalog coverage) and pass. Mechanical verification only — no playground exists yet to preview the motions, so the Validation Plan's own Try items (side-by-side comparison against v1, calling the by-name lookup from a scratch scene) were not performed by the human.

### Phase checks

| Phase promise | Result | What happened |
|---|---|---|
| Catalog reachable by name | not tested | Automated coverage only; not visually confirmed by the human |
| Catalog reachable by asset | not tested | Automated coverage only; not visually confirmed by the human |
| Dynamic values preserved | not tested | Automated coverage only; not visually confirmed by the human |
| Full coverage (99/99) | not tested | Automated coverage only; not visually confirmed by the human |

### Decision

- **Choice:** Not enough evidence

### Assumptions

| Assumption | Result | What showed this |
|-----------|---------|------------------------|
| The category taxonomy chosen for these 99 presets is sufficient for now, even though the deferred preset browser may later impose its own taxonomy. | inconclusive | |

### Backlog changes

- feature "Animation Catalog Playground" — added because the phase shipped with no way to visually verify the catalog; design already sketched via `mano ui`

## Phase 18 Review — 2026-08-18

### Validation

- **Result:** Tested everything in the playground; everything worked as expected.

### Phase checks

| Phase promise | Result | What happened |
|---|---|---|
| Open the playground | passed | |
| Browse by category | passed | |
| Pick a preset | passed | |
| Playback controls | passed | |

### Decision

- **Choice:** Keep the category-grid browsing approach as-is
- **Why:** Browsing by category does make it easy to spot a preset that looks wrong

### Assumptions

| Assumption | Result | What showed this |
|-----------|---------|------------------------|
| This playground is deliberately a narrowed version of the deferred "Preset Browser" backlog item (browse-and-preview only, no search/tags/favourites/duplicate) — not the final shape the catalog's discovery UI will take. | confirmed | |

### Backlog changes

- feature "Anima usage guide/tutorial (on/group/grid, built-ins, keyframes, dynamic values, easings)" — added: runnable examples covering `Anima.on`/`Anima.group`/`Anima.grid`, each demonstrating built-in animations, keyframes, dynamic values, and easings

## Phase 19 Review — 2026-08-19

### Validation

- **Result:** Everything was tested. The documentation covers basic plus some advanced material, suitable for a newbie.

### Phase checks

| Phase promise | Result | What happened |
|---|---|---|
| Features | passed | |
| Guides | passed | |
| Tutorials | passed | |
| Site builds | passed | |

### Decision

- **Choice:** Keep the documentation as shipped
- **Why:** Yes, the docs cover basic plus some advanced stuff, suitable for a newbie

### Assumptions

| Assumption | Result | What showed this |
|-----------|---------|------------------------|
| This phase's Features/Guides/Tutorials set is a deliberately narrowed, hand-picked slice of the deferred "Full documentation structure" backlog item — not the final information architecture. | confirmed | |

### Backlog changes

- None

## Phase 20 Review — 2026-08-21

### Validation

- **Result:** Not tested

### Phase checks

| # | Phase promise | Result | What happened |
|---|---|---|---|
| E1a | Open the playground: a 2D/3D selector is visible | signed off | |
| E1a+1 | Open any existing playground demo: a "go back" button in the header returns to the demo selector. | signed off | |
| E1b | Select 2D: only 2D demos are shown | signed off | |
| E1c | Select 3D: only 3D demos are shown | signed off | |
| E2a | Open any existing playground demo on a high-DPI display: it renders at the same relative size and clarity as the others | signed off | |
| E2b | Compare two different playground demos side by side at a non-default display scale: their scaling behaves identically | signed off | |

### Questions

| # | Question | Answer |
|---|---|---|
| Q1 | Does the 2D/3D selector make it easy to find a demo? | unanswered at close |
| Q2 | Does every existing playground demo now scale consistently at high DPI? | unanswered at close |

### Decision

- **Choice:** Not assessed

### Assumptions

| # | Assumption | Result | What showed this |
|---|-----------|---------|------------------------|
| A1 | The playground's inconsistent scaling can be fully resolved by adopting one shared scaling add-on, rather than needing per-demo fixes. | accepted | |

### Backlog changes

- None

### Addendum — 2026-08-21

#### Validation

- **Result:** Everything worked as expected; validated manually.

#### Outcome changes

- None

---

## Phase 21 Review — 2026-08-24

### Validation

- **Result:** Q2: yes. Q1: could not test manually because no existing example covers the interruption choices.

### Phase checks

| # | Phase promise | Result | What happened |
|---|---|---|---|
| E1a | Start a motion, then request another motion on the same property: the system identifies the active owner and applies the selected interruption behaviour | signed off | Not manually tested. |
| E2a | Start a motion using each supported interruption choice: the affected property reaches the result defined by that choice without simultaneous conflicting writes | signed off | Not manually tested. |
| E2b | Queue a second motion behind an active motion: the queued motion starts only after the active motion's policy-defined outcome | signed off | Not manually tested. |
| E3a | Open the demo selector and choose Showcase: Grid Showcase is listed and can be opened | passed | Q2: yes. |

### Questions

| # | Question | Answer |
|---|---|---|
| Q1 | Do the supported interruption choices make overlapping motion requests predictable enough to use without workarounds? | Not checked — could not test manually; needs example coverage. |
| Q2 | Does the Showcase category make Grid Showcase easy to find? | Yes. |

### Decision

- **Choice:** Nothing to decide

### Assumptions

| # | Assumption | Result | What showed this |
|---|---|---|---|
| A1 | The general interruption choices in this phase can be extended by deferred visual-state and layout-transition work without introducing a separate conflicting model. | accepted | |

### Backlog changes

- [feature] Motion interruption example coverage — added so people can manually exercise the interruption choices.

---

## Phase 22 Review — 2026-08-25

### Validation

- **Result:** Yes, all is working as expected. Layout transitions are now clear with no visual snap.

### Phase checks

| # | Phase promise | Result | What happened |
|---|---|---|---|
| E1a | Run the layout demonstration and trigger a supported layout change: every supported Control reaches Godot's final position and size without a visible snap. | passed | All working as expected; no visual snap. |
| E1b | Inspect the completed layout demonstration: the final arrangement remains the one selected by Godot. | passed | All working as expected. |
| E2a | Run each interruption scenario: replace, retarget, queue, and reverse each show a distinct resulting motion outcome. | passed | All working as expected. |
| E2b | Restart each interruption scenario: it returns to its defined starting state before the next run. | passed | All working as expected. |

### Questions

| # | Question | Answer |
|---|---|---|
| Q1 | Are the automatic layout transition and each supported interruption outcome clear enough to verify by watching their visual scenarios? | Yes, all is working as expected. Layout transitions are now clear with no visual snap. |

### Decision

- **Choice:** Nothing to decide

### Assumptions

| # | Assumption | Result | What showed this |
|---|-----------|---------|------------------------|
| A1 | The supported Control and standard-container cases are enough to establish the first automatic layout-transition behaviour. | confirmed | All working as expected. |

### Backlog changes

- None
