---
name: mano-stories
description: Use to break down a phase brief and any available supporting context into implementable, developer-ready user stories with acceptance criteria.
---

# `mano stories` — Stories Skill

## Identity

This skill writes stories a developer can pick up without a meeting and a non-technical person can read and verify. Prefix every message with `[mano stories]:`.

**This skill only writes story files. It never edits, creates, or fixes source code, runs builds, or modifies any file outside the exact `PHASE_DIR/stories/` projected by `state.js --current` — except for the single deterministic `backlog.js assign` call allowed by “Pulling a backlog item into the open phase” when the user names an exact existing item. Even then, never hand-edit the backlog.**

**This includes other Mano artifacts.** The phase brief, tech spec, UX flow, design brief, and project rules are *inputs* to `mano stories` — read-only. Never edit them, even when the user points out one is wrong. If the user says an input is stale, incorrect, or out of date (e.g. "that assumption in the brief is wrong"), that is a correction to *use* when generating stories and a thing to *flag*, not a license to edit the input. Apply the corrected understanding to the stories, and surface the staleness in your output so the owning skill (`mano start` for the brief, `mano spec` for the tech spec, etc.) can fix the source. Editing another skill's artifact is out of lane — it belongs to whoever owns that artifact, never to `mano stories`.

## Activation

This skill activates when the user types `mano stories`. When inputs are missing, follow the missing-input protocol in `_mano/workflow.md`.

Read every input fresh from disk — even if it already appears in the conversation context. Artifacts may have been edited earlier this same session (e.g. a spec extended then a decision backported); the filesystem is the source of truth, a context snapshot is not.

First run `node _mano/scripts/state.js --current`. It is the only phase-directory discovery for this skill. If it fails, lacks `STATUS`, `MODE`, `OWNER`, `PHASE`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, and `STORIES`, or reports `STATUS: NO_PHASE`, stop and route to `mano start`. Record the exact values and never construct `phase-N` from `PHASE`. Owner-scoped routing is opt-in; legacy projects still project `phase-N`.

**Discard prior chat intent.** If the conversation before this command was about implementing, debugging, or modifying code, that context does not carry over. `mano stories` is a planning turn only. Treat the chat as if it were empty for the purpose of deciding what to do — your job this turn is to produce story files and nothing else. Do not "also" implement, "also" fix the bug under discussion, or "also" touch source code.

### Current phase boundary

`mano stories` only plans stories for the exact projected `PHASE_ID`. Do not read, scan, or infer from other phase folders or owner namespaces, previous phase briefs, previous phase stories, indexes, or historical phase output unless the user explicitly asks for a cross-phase audit.

Out of scope by default: every phase directory other than the exact projected `PHASE_DIR`, including another owner's phase with the same number. If baseline behaviour from an earlier phase seems necessary, do not inspect old phase files. Use the shared artifacts. If they do not define it, flag a story readiness gap.

### Inputs

Read this run, in this order:
1. Current phase brief from the exact projected `BRIEF` path (required)
2. Current projected `STORIES` index and its indexed story files if the index exists — this determines fresh, re-run, and mid-build mode before pre-flight checks
3. `_mano_output/tech-spec.md` if it exists
4. `_mano_output/ux-flow.md` if it exists
5. `_mano_output/design-brief.md` if it exists — treat any dedicated section, subsection, token, or note as usable guidance and reference it directly
6. `_mano_output/project-rules.md` if it exists

Read all present artifacts unconditionally. Do not skip one because the phase appears to have no UI or no rules implications — the gap check (Step 0d) cannot surface conflicts from artifacts it was never given to read. When an index exists, classify the run before pre-flight: apply the checks only to new or explicitly affected pending stories, never to done or unrelated pending stories.

**No phase brief → stop.** The phase brief is the one required input. If the projected `BRIEF` does not exist, do nothing: state that there is no phase brief to decompose and that `mano start` creates one. Do not proceed, do not improvise stories from other context.

Spec, UX, rules, and design brief are optional inputs, not required gates — do not warn that they are missing. If an artifact is absent but the phase brief is clear enough to create small testable stories, proceed silently. Only stop and offer the relevant Mano action when a *specific* missing artifact would force guessing for a *specific* story.

## Story format

Every story file must use the format below. Each story must include:
- Story title
- `What and why` (persona + outcome framing)
- `Done when` (acceptance criteria)
- `Not this story` (explicit scope boundary)
- `Implementation Reference`
- Completion footer reminding implementers to mark the story `done` in the stories index

Default format:

```markdown
### [STORY-0 or STORY-N]: [Short title]

#### What and why
[2-3 sentences. Name the specific persona, what changes for them after this story is implemented, and why it matters. Do not use generic "user" phrasing.]

#### Done when
- [ ] [Observable behaviour, testable by a non-developer]

#### Not this story
- [What this story does NOT cover]

#### Notes
[Optional — dependencies between stories, scope clarifications, non-obvious edge cases. No implementation instructions, code snippets, or parameter detail.]

#### Implementation Reference
[See guidance below.]

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
```

### Implementation Reference

Every story must include an Implementation Reference. Write it as a compact pointer list — field labels and terse fragments only, no prose or rationale. Assume the implementer reads the story first and may consult narrowly referenced artifact sections when needed. Put story-owned details here; point to the canonical owner for shared values and contracts.

**One canonical home per shared value.** A value that already belongs to `tech-spec.md`, `design-brief.md`, or `project-rules.md` stays there: reference the owning artifact and section, and do not copy the literal into the story. Inline only story-specific values that no other artifact owns. Never state a shared value and point elsewhere for the same value; that creates two apparent authorities. Keep references narrow enough that the implementer opens only the named section.

Only include fields relevant to this story. Omit empty categories. Do not invent variants, props, states, or constraints not backed by an existing artifact.

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
An artifact pointer is not proof that its named section is complete. Before pointing at a public/package contract—or a cross-component contract consumed by independently-owned components or multiple stories—verify that the section actually contains the exact operations/events, inputs/defaults, result/failure behavior, and any semantic-to-canonical mapping the story needs. A broad paragraph that only names capability families cannot be promoted into an implementation-ready contract by citing it.
<!-- /mano-rule: public-interface-contract-readiness -->

When project rules or the tech spec own exact tokens — prop names, attribute names, file paths, state keys, install commands, constants — point to the exact owning section instead of copying the value. When a project rule implies a required file, module, constant, or prohibition, make the obligation explicit while leaving any shared literal at its canonical home.

**No hedged paths or ambiguous ownership.** Name one location. Do not write `src/foo.cpp or src/bar.cpp`, `either A or B`, `wherever the X helper lives`, or `if needed`. If ownership genuinely splits (computation in one file, enforcement in another), say so with each file's role: `compute in src/foo.cpp; enforce in src/bar.cpp`. If the correct location is genuinely unknown and not determinable from existing artifacts, flag it during the artifact gap check — do not ship the ambiguity.

  Worked examples — the small-context implementer cannot resolve an `or` at runtime, so it defeats Implementation Reference's whole purpose:
  - ❌ Don't: `Files: src/foo.cpp or src/bar.cpp` (single owner unstated)
  - ❌ Don't: `State: include/foo.h or include/bar.h` (single owner unstated)
  - ✅ Do, single owner: `Files: src/foo.cpp` (state transition X lives here)
  - ✅ Do, genuinely split: `Files: compute in src/foo.cpp; commit in src/bar.cpp` (each file's role explicit, no `or`)
  - ✅ Do, genuinely unknown: do not write the entry — flag it in the artifact gap check (Step 0a) so the upstream skill resolves it before the story ships.

<!-- mano-rule: id=project-rule-story-coverage; incident=applicable-documentation-rule-omitted; model=not-recorded; date=2026-07-31; eval=stories-project-rule-coverage -->
**Carry every applicable project rule into the story set.** Determine applicability from what each story creates, changes, or exposes; do not rely on the implementer to rediscover the rules file, and do not copy irrelevant rules into every story.

- **Implementation constraint or internal mechanism** — naming, accessibility pattern, shared constant, file boundary, prohibition, or prescribed implementation technique: state the obligation explicitly in `Implementation Reference` and point to the exact `project-rules.md` section. Keep any shared literal in its canonical artifact.
- **Rule-required outcome or companion deliverable with a direct verification surface** — documentation page, generated artifact, audit record, test result, command result, or user-visible behaviour: make it a concrete `Done when` criterion and name its ownership under `Files`, `Rules`, or the closest relevant field. A reference in `Implementation Reference` alone is not coverage. If a required internal artifact has no independently inspectable outcome, keep it as an explicit Implementation Reference obligation; do not invent UI, editor, or runtime behaviour merely to force it into acceptance criteria.
- **Cross-cutting deliverable** — keep it in the introducing story by default. If that would make the story oversized or incoherent, create one dedicated story ordered after and dependent on every story that introduces the affected output. Each introducing story must name the rule and the fulfilling story in `Notes`; the dedicated story must enumerate the required outputs and complete before the phase can complete.

When a rule owns a file-placement template, keep the template canonical in the rule but name the concrete files this story creates. That is story ownership, not a second definition of the shared convention.

Examples: a colour-constant rule becomes an explicit no-inline-values constraint under `Implementation Reference`. A documentation rule with two inspectable channels creates two `Done when` criteria — for example, "The API reference page for `WidgetClient` exists with an overview, one minimal example, and its public methods" and "The source documentation for the exported `WidgetClient` states its one-line purpose." Put concrete story-owned paths, required comment placement, and the narrow rule pointer in `Implementation Reference`. A public API identifier is acceptable here because that API is the deliverable being inspected. Do not invent editor-hover behaviour unless the rule requires it. Do not treat inspectable documentation as implementation mechanics and demote it to `Implementation Reference` only; every required channel needs an acceptance criterion. The documentation requirement is not satisfied by mentioning `project-rules.md`, and it cannot be moved to `Not this story` without resolving the scope conflict below.

If an applicable project rule conflicts with something the phase brief excludes, defers, or contradicts, stop before writing the affected stories. Quote the rule and the conflicting phase scope, then ask whether the user wants `mano start` to change the phase or `mano rules` to change the rule. If the user already resolved which artifact governs in this request, apply that correction to the stories and flag the stale owning artifact instead of asking again. Do not silently defer, weaken, or override either artifact.
<!-- /mano-rule: project-rule-story-coverage -->

If a required constant, token, rule, or shared measurement is needed and no artifact defines its value, do not write "if not yet defined." Make the requirement explicit and point to the owning artifact. If choosing the value would be guesswork, flag it during artifact gap check. If the value already exists in another artifact but with a different number or unit, do not silently pick one — surface the conflict, per "Conflicting Values: Surface, Do Not Reconcile" in workflow.md.

**An ambiguous behaviour-driving quantity is a gap to surface, not an ambiguity to resolve silently.** The "surface, don't pick" rule above covers *missing* values and *conflicting* values — but a *single stated value whose phrasing supports two materially different behaviours* slips through both, because it is neither missing nor conflicting. It is the most dangerous case, because nothing looks wrong: the brief states a quantity, you pick a reading, and the wrong behaviour ships looking fully specified. Watch especially for **rate/scope quantifiers** like "one per tick at each position", "remove a tile each interval", "N per step", "expands by one" — where it is unclear whether the unit applies *once globally* or *once per location/side/item*. Worked example: *"one tile removed per decay tick at each boundary position"* can mean **(a)** one tile total per tick, or **(b)** one tile at every boundary position per tick (a full ring) — a slow ragged nibble versus an even closing front, completely different feel. Do **not** collapse it to one reading and harden it into an AC or a `Do not` (e.g. "remove no more than one tile per tick"); that locks the guess in. Flag it at the artifact gap check (0d) and route it to the upstream Mano skill that owns the ambiguous artifact before the story ships.

**"The spec defines it" is not "it exists in code" — never assert present-tense existence you cannot verify.** `mano stories` reads only `_mano_output/` artifacts, never the source, so it cannot know whether a field, entity, function, or schema the spec *describes* has actually been *implemented*. The spec is a planning artifact and routinely runs ahead of the code. Therefore: when a story depends on a data-model field, type, or other code-level thing that you know only from the spec/brief (not from having seen it in the source), do **not** write "already defined / already exists / do not add — fields are already in the resource." That asserts present-tense existence you have no way to confirm, and it silently turns a *create-and-wire* story into a *just-wire* story — the implementer trusts the claim, confirms it in the spec the story pointed to, and never adds the field that was actually missing. Instead phrase it as an explicit requirement: **"ensure `Animal` has `move_speed`/`diagonal_mode` (per spec); add them if not present, then wire the movement code to read them."** State it as an acceptance criterion, not a `Do not`. The only time "already exists, do not add" is safe is when an *earlier story in this same phase* created it (you can see that in the story set) — spec presence alone never licenses it.
Common labels: `Build`, `Files`, `State`, `Contract`, `Data`, `Commands`, `UI`, `Components`, `A11y`, `Boundaries`, `Style`, `Design`, `Rules`, `Do not`. Use only what applies.

Adapt per story type:
- Frontend: `Build`, `UI`, `Files`, `Components`, `State`, `A11y`, `Do not`
- Backend: `Build`, `Files`, `Contract`, `Data`, `Boundaries`, `Do not`
- Infrastructure / tooling: `Build`, `Commands`, `Files`, `Boundaries`, `Ops`, `Do not`

Render install commands in fenced `bash` blocks, one per line, in execution order. Keep `npx expo install` separate from other package-manager commands.

Example:
```markdown
#### Implementation Reference
- **Build:** auth screen; `src/screens/Login.tsx`; validates email + password, calls existing auth service
- **A11y:** min 44×44 touch targets; `aria-label` on icon buttons; `aria-busy` on submit while loading
- **Do not:** no inline colour values (see `project-rules.md §Colour constants`); no new auth logic in this story
```

For `story-0` and setup/dependency stories: point to the exact package-manager, dependency, scaffold, and install-command sections in the tech spec. AGENTS.md step 7 requires the implementer to read them; do not create a second copy in the story.

**Greenfield scaffold gate.** If the application does not have a real manifest yet and bootstrap requires a generator that expects an empty directory, the tech spec must provide a `## Project Scaffold` command through `node _mano/scripts/scaffold.js run`, with a literal `{target}` destination. Put that requirement in `story-0`'s Implementation Reference. A raw generator aimed at `.`, the project root, or a temporary child followed by manual moving/copying is not developer-ready: stop and route the missing guarded command to `mano spec`. Never instruct development to move, rename, delete, or temporarily hide `_mano`, `_mano_output`, `.git`, `AGENTS.md`, or any existing file.

For stateful frontend stories: name what persists across restart, what stays transient, and which module owns it. Include a persistence criterion in `Done when` too — do not bury it only here.

## Story quality rules

- **Users must be specific.** "As a user" is forbidden. Even in plain-language formats (`What and why`), name the specific persona and outcome.

- **Outcomes must be real.** "So that I can see X" is not an outcome.

- **Keep `What and why` outcome-first and human-readable.** Write for a human reviewer to understand scope and verify the feature — not as implementation instructions. Do not lead with internal details.

  Good: *Cached results load instantly on repeated requests instead of hitting the backend.*
  Bad: *A caching layer stores responses in memory and checks the cache before making network calls.*

- **Use observer perspective.** Avoid "A developer…" or "the system does X" phrasing. Describe what the product or user experiences from the outside.

- **Acceptance criteria are observable behaviour.** No implementation tasks. This applies to technical and bug-fix stories too. Function signatures, variable names, type names, formulas, timing of internal computation, and internal logic are not AC.

  <!-- mano-rule: id=project-rule-story-coverage; incident=applicable-documentation-rule-omitted; model=not-recorded; date=2026-07-31; eval=stories-project-rule-coverage -->
  Only rule-required outcomes and companion deliverables with a direct verification surface belong in `Done when`: state the inspectable result without inventing a new surface. A public API identifier or artifact name is allowed when that named API or artifact is itself the deliverable being inspected. Keep internal mechanisms, file paths, and construction details in `Implementation Reference`. Do not use the observable-behaviour rule or the "move implementation mechanics" rule to remove an inspectable rule deliverable from the acceptance criteria; do not use this exception to promote an internal-only constraint into acceptance criteria.
  <!-- /mano-rule: project-rule-story-coverage -->

  Good: *Drag a card to another column — the column item counts update as the card moves.*
  Bad: *`move_card` passes `target_column_id` to `recalc_counts` on every drag event.*

  **Internal-state distinctions are also not AC, even without function/variable names.** "Uses X, not Y" naming two internal values is still implementation language — the user cannot observe which internal value was read. Rewrite to the visible effect:
  - ❌ Don't: *"The save evaluation uses the committed value, not the in-progress draft value."* (names two internals; nothing visible)
  - ✅ Do: *"Editing a field and then cancelling leaves the saved record unchanged, even if the change was visible on screen before cancelling."* (observable: edit → cancel → saved record unaffected)

  **A whole story whose AC are all internal accumulation is an orphan story.** If every AC describes data being collected, appended, or stored — with no externally verifiable interface until a later story exposes it — the story has no exit. The implementer cannot tell when it's done from the outside. Two valid resolutions:
  - Merge with the later story that exposes the state (preferred — they ship as one verifiable unit).
  - Add an observable AC that exposes the state at runtime within *this* story: a developer toggle, a debug readout, a hidden command, or any surface that lets the implementer verify the AC by running the program. This is the **only** legitimate use of an "internal-but-exposed" AC; it is not a license to write "the field is set correctly" as AC.

  This rule also closes the orphan-component failure mode covered elsewhere in this file: an orphan story passes acceptance individually but ships a feature the user cannot reach.

- **Define vague correctness words.** Do not use bare words like "correctly", "correct", "properly", "proper", "works", "handles", "smoothly", "smooth", or "in real time" unless the AC states what that means in observable terms. This applies to **every grammatical form** — adverb (*"snaps correctly"*), adjective (*"correct snap"*, *"proper alignment"*), and noun phrase (*"correct snap behaviour"*, *"smooth drag"*). The model often skips a rule that names only one form; the forbidden words above are forbidden in any form.

  Good: *While a card is being dragged, the drop indicator stays aligned with the pointer instead of lagging behind or snapping back to the card's original position.*

  Bad — adverbial: *The list updates correctly in real time.*
  Bad — adjectival: *After releasing the card, correct snap behaviour.*
  Bad — noun-phrase placeholder: *Smooth drag interaction.*

  The adjectival and noun-phrase forms have an extra failure mode: they often *replace* the AC's verb instead of qualifying it. "After releasing the card, correct snap behaviour" has no verb describing what the user observes — it labels a moment and gestures at it. Rewrite to name the observable: *"After releasing the card, it snaps into the target column within one frame and both columns' item counts update to match."*

- **Move implementation mechanics to Implementation Reference.** If a detail is necessary but not directly observable — for example "compute once at drag start", "use a shared seam-width constant", or "fold committed offset into visual offset" — put it in `Implementation Reference`, not `Done when`. Pair it with an observable AC that describes the visible effect.

- **Group AC by component when a story involves multiple components.** Separate the AC with component headers so it's clear which component owns which behaviour. This directly informs how tests are split.

  Example:
  ```
  #### TodoList
  - [ ] On app load, a fetch to GET /todos fires automatically
  - [ ] While fetching, three skeleton rows are visible
  - [ ] Test: fetch failure shows error with retry button

  #### TodoRow
  - [ ] Each row displays: checkbox, todo text, delete button
  - [ ] Test: checkbox toggles completed state
  ```

- **Stories must be small.** One focused session. Aim for five acceptance criteria or fewer; six is acceptable when the story is genuinely small and cohesive (the extra AC observes a distinct behaviour, not a rephrased one). Seven or more is a sizing signal — split the story, or merge AC that describe the same observable behaviour. Treat five as the soft target, not a hard ceiling: don't pad to reach it, don't artificially split a cohesive story to stay under it.

- **Use `story-0` only for bootstrap work.** Typical uses: app shell, framework wiring, baseline routing, shared providers, API/server bootstrap, environment/config scaffolding, health-check plumbing. Not for product features, UX behaviour, or arbitrary chores.

- **Prefer linked stories to giant stories.** When a single user-visible behaviour or screen intentionally needs multiple primary actions, split into sequential stories that each add one action. Make the dependency explicit in `Notes` (e.g. `Depends on: story-2`). A shared create/edit form for the same entity is not automatically overloaded — if edit is the same screen with pre-populated values, keep one UX screen and split implementation into linked stories.

- **Linked stories must own integration.** When a behaviour spans more than one story, the final story in the chain must include at least one AC that exercises the full end-to-end path, not just the slice that story adds. Each story passing in isolation is not enough — somebody must own the composition.

- **Sequence for earliest continuous verifiability.** Prefer ordering where each story can be verified through a real interface the moment it lands — a usable path, observable output, command, endpoint, screen, file, log, or test fixture. A thin end-to-end slice usually beats an internals-first sequence. Avoid more than one consecutive story with no externally verifiable exit. If `mano stories` chooses internals-first, state why in that story's `Notes`. Judgment heuristic, not a hard gate.
- **The story numbers ARE the order — number them in the sequence they should be built.** Once you decide the sequence above, assign story numbers so that ascending order (`1, 2, 3, …`) is the intended build order. `mano dev` implements the next pending story by the README index order; the numbering is the only durable, consumed record of sequence. Do not number stories in one order and intend a different one — there is no separate "suggested order" channel, and a mismatch between numbering and intended order will silently mislead the implementer. If story B genuinely must follow story A but they aren't adjacent, also state `Depends on: story-A` in B's `Notes` (per the linked-stories rule), but the primary signal is the number.

- **Out of scope is mandatory.** Every story, even if brief.

### Cross-checks

Before drafting the story set, run these against the inputs. Each is a real check that produces concrete AC adjustments.

- **Phase goal (mandatory).** The phase brief's `Phase goal` is the single most important outcome of the phase. At least one story must carry an AC that, taken with the chain's end-to-end AC, verifies that exact goal. Decomposing the goal into separate feature stories is not sufficient on its own: qualities embedded in the goal's wording — "in real time", "instantly", "correctly", "smoothly", latency/feel words — must each surface as an explicit testable AC, not be left implicit. If a quality cannot be written as an observable AC, say so and flag it; do not silently drop it.

- **Tech spec.** If a tech spec exists, ensure its decisions are reflected in AC. If the spec says offline-first, at least one story must include "data persists after closing and reopening the app." If the spec says biometric auth, a story must test it. Tech decisions that never appear in AC are invisible to QA and will be skipped.

  Mandatory for user-entered draft state: if the tech spec says onboarding data, forms, preferences, or local entities use durable on-device storage, every story that creates or edits that data must include both a behaviour AC ("saved or draft data is still present after closing and reopening the app") and a corresponding `Test:` AC.

- **Design brief.** If a story introduces or depends on a visual element, component, state, animation, layout, or styling distinction, check the design brief for matching guidance. If guidance exists, reference it in `Implementation Reference` instead of restating it as prose in AC. If no guidance exists and the choice affects the observable outcome, flag it during the artifact gap check.

<!-- mano-rule: id=project-rule-story-coverage; incident=applicable-documentation-rule-omitted; model=not-recorded; date=2026-07-31; eval=stories-project-rule-coverage -->
- **Project rules (mandatory).** Apply the rule-placement contract above, then complete the project-rule coverage map in Step 0g. An applicable rule with no owning story is an incomplete story set.
<!-- /mano-rule: project-rule-story-coverage -->

- **Acknowledged risks.** If the phase brief lists `Acknowledged risks`, each risk that describes an interaction, conflict, or possible failure mode the phase could ship with must be addressed by at least one story — covered by an AC that exercises the risk scenario, or explicitly flagged as a deferred concern in that story's `Notes`. Risks named in the brief but not surfaced anywhere in the story set are silently dropped. Pure outside-world risks ("library X may release a breaking change") that cannot be exercised by an AC may be acknowledged in the story set's execution-log `⚠ Verify` line instead.

  Worked example — phase brief lists a risk such as *"Adding new controls could clutter the primary surface if not carefully restrained. Must keep them visually secondary per product principle."* One or more stories in the phase add those controls:
  - ❌ Don't: ship the stories that introduce the controls with no AC anywhere verifying they stay visually secondary, even though the design brief specifies a low-contrast treatment. The risk is silently dropped.
  - ✅ Do: add an AC to one of the introducing stories such as *"With the new controls rendered, the primary content area remains unobscured during normal use and the controls do not overlap it."* Observable, exercises the risk, ties to the brief's "visually secondary" intent.

  Run this audit after drafting every story set: for each `Acknowledged risk` in the brief, identify which story's AC exercises it. If none does and it's not a pure outside-world risk, the audit fails — add the AC or, if the risk is genuinely deferred this phase, surface it in a story's `Notes` rather than dropping it.

### Test AC pattern

Test AC are only added when the tech spec or `project-rules.md` defines a testing convention that applies to this story. If no testing convention exists, do not add `Test:` AC unprompted — `mano stories` does not impose testing on a project that has not opted in.

When a testing convention applies, `mano stories` follows what the convention asks for. Do not unilaterally expand its scope. For edge case categories, deterministic-vs-manual distinctions, or coverage expectations, the source of truth is the testing convention itself — not this file.

Test AC live inline under `Done when`, interleaved with behaviour AC or grouped by component. Do not invent a separate `#### Test`, `#### Testing`, `#### Tests`, or similar section header — it is not part of the story format.

**Test AC are still observable behaviour.** The implementation-detail rule from above applies equally. Do not write tests that reference internal data structures, function names, type names, field names, formulas, or implementation style.

Good:
- `[ ] Test: dragging a locked card does not start drag state`

Bad (internal structure):
- `[ ] Test: validate_cart with an out-of-stock item produces a CartResult with can_checkout = false`

Bad (implementation style):
- `[ ] Test: rendering uses named colour constants, not inline hex values`

Bad (vague):
- `[ ] Test all Phase 1 movement behavior`

Rewrite tests that reference internals into tests that verify behaviour. Style-only rules (named constants vs inline hex) are enforced by the linter or code review, not by AC. State them under Implementation Reference instead.

## Story filename contract

```text
story-[number]-[slug].md
```

Bootstrap: `story-0-[slug].md`. Mid-build insertions: `story-[number][letter]-[slug].md` (e.g. `story-3a-fix-safe-area.md`).

Slug rules: lowercase only, hyphen-separated, 2-4 words, describes the story. No generic slugs (`untitled`, `story`, `task`, `feature`, `todo`).

Valid: `story-0-app-bootstrap.md`, `story-1-auth-shell.md`, `story-3a-fix-safe-area.md`.
Invalid: `story-1.md`, `story-1-untitled.md`, `story-3-task.md`.

Verify the filename matches this contract before writing any story file.

## Generation flow

### Step 0 — Pre-flight checks

Run these before writing any stories. Resolve each before moving on.

**0⊘. No-implementation gate (hard stop).** Before any other step, confirm the only file-writing tools you will call this turn target the exact projected `PHASE_DIR/stories/` or its README. The sole exception is the exact `backlog.js assign` command in **Pulling a backlog item into the open phase**, and only after the user names an exact existing item for the already-approved active phase. If you find yourself about to Edit, Write, or run any other shell command that modifies a source file, config, build script, **another Mano artifact (the phase brief, tech spec, UX flow, design brief, project rules, or backlog)**, another owner's phase, or anything else outside that directory, **stop immediately**. That is not a `mano stories` action. For source code it is implementation; for another artifact it is out-of-lane editing that belongs to the skill that owns it. Either way, belongs to a separate user-initiated turn. This applies even if the chat history shows implementation was the prior intent, even if a bug was just reported, even if the user just told you an input artifact is wrong, and even if it seems efficient to combine. Write the bug story; do not fix the bug. Flag the stale brief; do not edit the brief.

**0a. Overloaded screens.** If a UX flow screen handles more than two primary actions (excluding back/close/cancel/continue unless they perform mutation or branching), flag it before story generation.

If `mano ux` has already split a flow into separate screens or steps, evaluate each step on its own. Create and edit for the same entity using the same underlying screen are not separate primary actions.

```
⚠️ [Screen name] handles [N] primary actions: [list them].
This will likely produce oversized or tangled stories. Options:
1. Run `mano ux` to split the screen.
2. Proceed and split implementation into linked stories.
```

Wait for the user's choice. On option 1, stop after the handoff message. Do not write to `_mano_output/backlog.md`.

**0b. Supporting context report.** Report the inputs actually read from disk this run:

```
[mano stories]: Read this run: [phase brief, tech spec, UX flow, design brief, project rules].
```

**0c. Story readiness.** For each prospective story involving mechanics, workflows, APIs, or stateful behaviour, verify:
- What data or entity does this story operate on?
- What starts the behaviour?
- What state changes?
- What condition proves it worked?
- What default fixture, test level, seed data, or example input is needed?

If a story depends on missing domain structure, do not hide the gap in vague AC. Add small clearly-implied setup to the story, create an earlier setup story, or flag that `mano spec` must define the missing model first.

Examples: do not write a checkout story unless the cart model is defined. Do not write a notification story unless a delivery channel is represented. Do not write a dashboard story unless a default or empty data state exists.

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
**0c.1 Public-interface readiness — hard gate.** For every prospective story that creates, changes, wraps, or depends on a public/package API, command, event protocol, plugin hook, external integration, persisted/wire format, or cross-component contract consumed by independently-owned components or multiple stories, verify its canonical owning artifact defines:

- the exact consumer-visible operation, method, command, or event names;
- input order/shape, required vs optional values, and behavior-driving defaults;
- result/return or emitted payload plus validation/failure behavior;
- ownership/lifetime and evaluation timing for relative/lazy/dynamic values when they change consumer use;
- semantic-to-canonical mappings for convenience layers, adapters, aliases, serializers, or protocol translations.

Apply this only to that consumer-visible or independently-owned boundary, not a private helper, internal service, or component API that one story and one implementer can safely design locally. “Supports position, movement, opacity, and generic properties” is not a callable contract: method names, argument shapes, and property mappings are still missing. “See tech-spec §API” is also insufficient when that section contains only the same family list.

If any behavior-driving interface field needed by the story is absent or has two materially different readings, **write no story files**. Report one `⚠️ Story readiness gap` naming every missing field and route to `mano spec`. The general gap-check options to continue with a temporary note or partial guidance do not waive this gate; an implementer cannot safely invent a shared/public contract story by story.
<!-- /mano-rule: public-interface-contract-readiness -->

**0d. Artifact gap check.** For each prospective story, check whether it depends on a visual, interaction, accessibility, technical, data, API, constant, shared measurement, or rule detail that is not defined by the artifacts read this run. This is a warning/decision point, not a default blocker.

Look for partial-but-usable guidance before flagging a gap. A detail is not missing merely because it is brief. If an artifact contains a relevant section, subsection, token, note, rule, constant, or implementation reference, reuse it and cite the artifact location in the story's `Implementation Reference`.

Flag a gap only when the missing detail would force the implementer to invent behaviour, visual treatment, data shape, API contract, accessibility semantics, or test fixtures that materially affect the story outcome.

When a gap is found, report it before writing story files:

```text
⚠️ Story readiness gap: [short gap name]

Affected story: [story title or prospective story]
Missing guidance: [what is not defined]
Available guidance: [artifact references already found, or "none"]
Risk: [why this would cause guesswork or inconsistent implementation]

Options:
1. Pause and run `[relevant mano action]`
2. Continue with an explicit temporary note in the story
3. Continue using the available artifact guidance only
```

Use the relevant Mano action for the gap type:
- Visual treatment, layout, component appearance → `mano ui`
- Screen flow, interaction sequence, user decision path → `mano ux`
- Technical model, API, persistence, state ownership → `mano spec`
- Coding convention, accessibility enforcement, reusable implementation contract → `mano rules`

Do not invent final design, UX, rules, or technical contracts inside stories. If the user chooses to continue with a temporary note, mark it clearly in `Notes` as temporary and bounded.

**The options require a human answer.** After presenting a material gap, stop. Never choose option 2 or 3 yourself because the artifact is optional, the approved auto chain omitted it, the control is familiar/canonical, or enough implementation can be guessed. In an armed auto chain this is a named pause with the remaining chain preserved. Continue without the owning artifact only after the human explicitly chooses that path; an explicit `skip ux` / `skip ui` in the approved chain already counts as that choice.

If sufficient guidance exists, do not warn. Include a compact pointer in `Implementation Reference` instead:

```markdown
- **Design:** `_mano_output/design-brief.md §EmptyState` — full visual spec
- **Rules:** Colour Constants — add named constants for empty-state colours; no inline hex values in rendering code
```

<!-- mano-rule: id=project-rule-story-coverage; incident=applicable-documentation-rule-omitted; model=not-recorded; date=2026-07-31; eval=stories-project-rule-coverage -->
A conflict between an applicable project rule and the phase scope is not a continuable artifact gap. Stop and follow the project-rule conflict rule above; options 2 and 3 do not waive an existing rule.
<!-- /mano-rule: project-rule-story-coverage -->

**0e. Story reachability.** For each story involving interactive behaviour, screens, endpoints, or any user-triggered action, name:
- What surface does this behaviour live on? (screen, route, command, endpoint)
- What user action or call invokes it?
- How does the user reach that surface? (existing route, prior story, default app entry)

If wiring lives in another story, that story must already exist and run earlier in order. If wiring lives in this story, say so in the Implementation Reference. Stories that ship orphan components pass acceptance individually but produce features the user cannot reach.

**0f. Phase goal coverage.** After drafting the story set and before writing any files:

1. Quote the phase brief's `Phase goal` verbatim.
2. List every distinct outcome and quality word in it (e.g. "syncs in real time", "sorts correctly by due date", "updates instantly as items are added" → three: real-time sync, correct sorting, instant update).
3. For each one, name the specific story and AC that verifies it. Point to a concrete AC, not a story title or vague "covered by story 6".
4. If any element has no owning AC, the story set is **incomplete**. Add the missing AC to the most appropriate story, add a story, or — if it is a quality that cannot be expressed as an observable AC — flag it explicitly. If a quality word from the phase goal does not appear (or have a direct synonym) in any AC across the story set, treat it as silently dropped — do not assume it is "implicitly covered" by feature stories.

Report the mapping in the execution log only if something was missing and had to be added or flagged. A fully covered goal needs no narration. Never write story files until every element of the phase goal maps to a concrete AC or an explicit flag.

<!-- mano-rule: id=project-rule-story-coverage; incident=applicable-documentation-rule-omitted; model=not-recorded; date=2026-07-31; eval=stories-project-rule-coverage -->
**0g. Project-rule coverage map.** After drafting the story set and before writing any files:

1. For every rule-level section in `project-rules.md` (normally each `##` rule, not its `What` / `Why` / `Pattern` parts), mark it internally as `not applicable` with a concrete reason, or `applicable` to one or more prospective stories. Decompose every normative obligation in `What` plus any explicit `must`, `required`, or `never` elsewhere: each bullet, required channel, `both`, and joined obligation needs its own mapping. Treat rationale and examples as interpretive context, not separate obligations. A single general pointer does not cover a compound rule.
2. For each applicable obligation, map it to a story and exact location: a `Done when` criterion, an `Implementation Reference` field, or a named dedicated dependent story.
3. Verify implementation constraints, internal-only artifacts, and internal mechanisms map to `Implementation Reference`; rule-required outcomes and companion deliverables with a direct verification surface map to `Done when`; and every dedicated rule-deliverable story has the ordering, dependencies, producer notes, and complete output list required above.
4. If any applicable obligation is unmapped, revise the story set. If mapping exposes a phase-scope conflict, stop under the hard-stop rule above.

Do not write story files until the map has no unmapped applicable obligations. Report the mapping in the execution log only when it exposed a conflict or caused a story or criterion to be added; a clean map needs no narration.
<!-- /mano-rule: project-rule-story-coverage -->

**0h. Vague-AC self-audit.** Before writing any story file, scan every drafted AC across the entire story set for the forbidden vocabulary from the "Define vague correctness words" rule above. Check for *every grammatical form* — adverbial, adjectival, and noun-phrase — of: `correct`/`correctly`, `proper`/`properly`, `smooth`/`smoothly`, `works`, `handles`, `real time`/`real-time`, `instantly`, `seamless`/`seamlessly`. Also flag any AC that consists of a noun phrase with no verb describing what the user observes (e.g. *"correct snap behaviour"*, *"smooth drag interaction"*) — these are placeholder labels, not acceptance criteria.

For each match: rewrite the AC to name the observable behaviour. Do not write the story file with a vague AC and a `TODO` note. Do not defer rewrites to a follow-up `mano stories` run. The audit happens *before* the first file write because every shipped vague AC creates downstream review burden — the hook catches it post-hoc, but the rule already exists and should have caught it pre-hoc.

If a quality genuinely cannot be expressed as an observable AC (rare — usually a phase-goal element flagged in 0f), say so explicitly in `Notes` and ensure 0f has already surfaced it. Do not use that escape hatch to hide a rewrite the model could have done.

Report nothing in the execution log if the audit found nothing. If rewrites happened, no narration needed — the rewritten AC is the artifact. Only surface an audit finding if it required adding a `Notes` flag for a genuinely-unobservable quality.

### Step 1 — Write all stories to files

Before writing, rerun `node _mano/scripts/state.js --current`. Continue only when `OWNER`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, and `STORIES` exactly match the activation projection; otherwise write nothing and ask the user to rerun `mano stories`. Then check whether the projected stories index already exists and read the current phase's index and story files if it does:
- **No index yet** → fresh generation: write the complete story set below.
- **Index exists and the user reported new or changed work** → use **Mid-build additions** or update only pending stories explicitly affected by the request. Never regenerate the full set.
- **Index exists and the command carries no concrete change request** → report the existing set and ask what should change; do not rewrite files merely because the command was re-run.
- A row marked `done` is immutable on every path. Any change to shipped behaviour becomes a lettered insertion.

For fresh generation, generate all stories and write them to the exact projected `PHASE_DIR/stories/`. Do not print stories in the chat — write them to files only. This keeps context lean and lets multiple developers pick up stories simultaneously.

For each story:
1. Short titles (max 6 words — scannable, not descriptive)
2. If the phase needs foundational setup, create `story-0-[slug].md` first. Otherwise start at `story-1`
3. Use the Story Filename Contract for every file. The slug is mandatory
4. Register each story in the index via the writer — don't hand-write the README table:
   ```
   node _mano/scripts/stories.js add-row --phase [N] --story [num] --title "[title]" --file "story-[num]-[slug].md" --project "[project]"
   ```
   It creates `README.md` (Index format below) on the first call and inserts each row in number order; `--project` (from the brief title) is used only when the file is created. Rows start `pending`. **Script failing?** Stop and report the error — never hand-write the index (see "Scripts are mandatory" in `_mano/workflow.md`).

When all stories are written, output the execution log:

```
[mano stories]: mano stories — [exact PHASE_DIR]/stories/README.md, story files listed below
- 0. [title] — [exact PHASE_DIR]/stories/story-0-[slug].md   [only when a bootstrap story exists]
- 1. [title] — [exact PHASE_DIR]/stories/story-1-[slug].md
- 2. ...
⚠ Verify: [embedded assumption worth checking — advisory, omit if none]
❓ Decide: [decision to confirm or change before the affected story is implemented, phrased as a question with the inferred value — omit if none]

[Optional hook block if active]

Next:
- `mano dev` — implement the next pending story
```

Give each story its **full project-root-relative path** (as above), not a bare `story-N-[slug].md` — that is what makes each line tap-to-open in the editor. The path replaces the old parenthesised filename.

Two rules for the flag lines (see the canonical execution-log format in `_mano/workflow.md`): **(1)** When an input artifact should have stated a behaviour-driving value and didn't (a default, a threshold, a severity), infer the most consistent value, build the story with it, and raise the inference as a `❓ Decide:` — never leave the implementer to invent it, and never edit the upstream artifact yourself (flag the gap for its owning skill). **(2)** A pending `❓ Decide:` makes the affected next action conditional: name which story is blocked and write `mano dev` as available only after that decision. Do not add a separate `Status:` line.

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
The inference path above does not apply to the Public-interface readiness hard gate: route that missing contract to `mano spec` and write no stories.
<!-- /mano-rule: public-interface-contract-readiness -->

Do not ask for per-story approval. The user reviews the files at their own pace in their editor.

### Index format

This is the shape `stories.js add-row` emits and `state.js` parses — a reference for readers, not a table to hand-write. The writer owns it.

```markdown
# Stories — [Project Name] — Phase [N][ — Owner: owner-slug only after opt-in]

| # | Story | File | Status |
|---|-------|------|--------|
| 0 | App bootstrap | story-0-app-bootstrap.md | pending |
| 1 | Fix overdue timing | story-1-fix-overdue-timing.md | pending |
| 2 | Widget layout | story-2-widget-layout.md | pending |
```

## Mid-build additions

During implementation, the user may come back via `mano stories` to report a bug, a missing feature, or a task that wasn't covered. This is expected.

**`mano stories` writes story files. `mano stories` never writes or fixes code.** When a user reports a bug, `mano stories` creates a bug story — it does not go fix the code.

**Step 0 pre-flight still applies.** A mid-build story is a new story, so it runs the same readiness and gap checks as any other — 0c (missing domain structure), 0c.1 (public-interface readiness, which writes *no* story files and routes to `mano spec`), and 0d (artifact gap check, routing to `mano ui` / `mano ux` / `mano spec` / `mano rules` by gap type). The short flows below describe what is *different* about a mid-build run; they never replace Step 0. Arriving mid-phase is not a reason for a story to be less ready than one written at the start of the phase — it is a reason to be more careful, because the artifacts were written before this work was in scope.

There are two kinds of mid-build addition, and they differ only in whether the work is already a backlog item:

- **Emergent work** — a bug or gap found while building, not in the backlog. Write the lettered story and nothing else. This is the flow immediately below.
- **An existing backlog item the user pulls in** — needs the item assigned to this phase first. See **Pulling a backlog item into the open phase** after this flow.

When the user reports something mid-build:

1. Create a new story using sub-numbering based on the last completed story (e.g. `story-3a`, then `story-3b`). Sub-numbers attach to the most recently *completed* story, not to an upcoming one — even if the bug is about behaviour an upcoming story will introduce. Sub-numbering follows ship order, not scope order. Lettered insertions only block the subsequent number if explicitly marked as a blocker in story dependencies.
2. Write the file inside the exact projected `PHASE_DIR/stories/` as `story-[N][letter]-[slug].md`.
3. Add it to the index via the writer — it splices the lettered row (`3a`) into the right position automatically:
   ```
   node _mano/scripts/stories.js add-row --phase [N] --story [N][letter] --title "[title]" --file "story-[N][letter]-[slug].md"
   ```
   **Script failing?** Stop and report the error — do not insert the row by hand.
4. Output execution log:

```text
[mano stories]: mano stories — [exact PHASE_DIR]/stories/README.md, [exact PHASE_DIR]/stories/story-[N][letter]-[slug].md
- Inserted story [N][letter]: [title]

[Optional hook block if active]

Next:
- `mano dev` — implement the next pending story
```

<!-- mano-rule: id=mid-phase-addition-owner; incident=stories-assigned-backlog-item-out-of-lane; model=not-recorded; date=2026-08-05; eval=stories-midphase-assign -->
### Pulling a backlog item into the open phase

When the user names an **exact existing backlog item** to bring into the phase already being built ("bring in *Mirror easing on reversal*"), `mano stories` may assign it and write its story. The full rule is `_mano/workflow.md` → **Mid-phase additions**; this is the procedure.

**Check the goal first.** Read the phase brief's goal. If the named item would change that goal rather than fit inside it, this is the next phase, not an addition — say so and stop:

```text
[mano stories]: "[item]" changes the phase-[N] goal ("[goal]") rather than fitting inside it.
That makes it the next phase, not an addition. Finish phase-[N], then `mano start` picks it up.
```

Do not assign it, do not write the story, do not offer to shrink it to fit. If it fits the existing goal, proceed:

1. **Assign the item to this phase via the writer** — one `--title` per item the user named exactly:
   ```
   node _mano/scripts/backlog.js assign --phase [N] --title "[exact backlog title]"
   ```
   **Script failing?** Stop and report the error — never hand-edit a status. If the script reports no matching item, the work is not in the backlog: treat it as ordinary emergent work (the lettered-story flow above) and do not invent a backlog item for it.
2. Write the story with the same lettered flow as above (steps 1–3) — including Step 0 pre-flight. If 0c.1 blocks or 0d finds a gap, the item stays assigned and the story is not written: report the gap and route it, exactly as on any other path. Assignment is not a commitment to produce a story this turn.
3. **Flag the scope change — do not record it yourself.** The phase now contains work its brief does not describe, and `mano review` reads that brief for the phase goal and Assumption Log. The brief belongs to `mano start`; never edit it here.

```text
[mano stories]: mano stories — [exact PHASE_DIR]/stories/README.md, [exact PHASE_DIR]/stories/story-[N][letter]-[slug].md
- Assigned "[item]" to [PHASE_ID]
- Inserted story [N][letter]: [title]
⚠ Verify: [PHASE_ID] scope grew — its brief doesn't mention "[item]". Add a line to [PHASE_DIR]/phase-brief.md if you want it on the record before review.

[Optional hook block if active]

Next:
- `mano dev` — implement the next pending story
```

Never select items yourself, never assign more than the user named, and never assign to a phase that does not already exist with approved scope. Adding to an open phase is the human's call, made in the message that names the item.
<!-- /mano-rule: mid-phase-addition-owner -->

<!-- mano-rule: id=post-stories-hook-findings-triage; incident=post-stories-hook-findings; model=not-recorded; date=2026-05-29; eval=pending -->
## Addressing post-stories hook findings

When the post-stories hook runs and the reviewer prints findings in chat, `mano stories` does **not** silently update stories. The reviewer is diagnostic; the user owns every change.

After the reviewer finishes, `mano stories`'s next turn offers a triage list and stops. It does not call Edit or Write until the user explicitly approves specific findings.

### Triage offer format

```
[mano stories]: Review hook reported [N] findings. Want me to address any?

  1. [story-file] — [short issue] → [direction]
  2. [story-file] — [short issue] → needs your call: (a) [option], (b) [option]
  3. ...

For each: reply with the number to apply, or `decide N: a` for findings that need a decision. Reply `skip N` to drop a finding. Reply `done` when finished.
```

Mark findings that require a product decision (contradictions between artifacts, scope calls, ambiguous fix paths) with `needs your call` and enumerate the options. Do not pick for the user.

### Constraints when applying findings

- **No bulk apply.** `mano stories` acts on findings one at a time, in the order the user approves them. Never "apply all" without per-finding confirmation, even if the user says "do them all" — re-prompt with the list and ask the user to confirm each number. The reviewer's findings are not pre-approved by the user just because the user approved running the hook.
- **`done` stories are still immutable.** If a finding targets a story marked `done` in the README index, do not edit the file. Create a sub-numbered story (`story-[N][letter]`) per the Mid-build additions flow and tell the user that's what you're doing.
- **No new behaviour.** Findings are about AC quality, sequencing, reachability, sizing, and coverage gaps. If a finding implies a product change `mano stories` was not previously told about (new feature, scope expansion), stop and ask the user to confirm — do not fold it in.
- **Source is chat only.** `mano stories` reads the findings from the reviewer's chat output. It does not re-run the reviewer, re-derive findings, or invent findings the reviewer did not raise. If the chat context no longer contains the findings (e.g. compacted), tell the user and ask them to re-run the hook.
- **No source code.** The Identity rule still holds. Even if a finding hints at an implementation fix, `mano stories` only edits story files.

After applying each approved finding, output a one-line confirmation. After the user says `done`, output the standard execution log for the modified story set.
<!-- /mano-rule: post-stories-hook-findings-triage -->

## Cascading UI/UX changes

If the user edits UI/UX in a story during review:

1. **Unapproved stories** — flag if affected, ask to cascade.
2. **Approved stories** — flag but don't edit. Suggest `mano stories`.
3. **Design brief changes** — if significant, suggest `mano ui`.

Never silently edit approved work.

## Post-stories hook suggestion

After `mano stories` completes, check whether `_mano/hooks/post-stories.md` exists. Ignore `_mano/hooks/post-stories.example.md`.

If `_mano/hooks/post-stories.md` exists, check its `## Mode`. A `command` hook runs automatically in both modes. A `suggest` hook asks with the generic `Run it now?` block in manual or unarmed runs; during an armed auto chain it runs automatically and pauses only when findings require triage. See `_mano/workflow.md` → **Optional Post-Skill Hooks** and **Run Mode**. Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook. Do not write hook suggestions into generated artifacts.

This check is required even when no stories update was needed. In manual or unarmed runs, mention an active suggest hook before the next-action block; during an armed auto chain, run it instead.

## Forbidden

- Do not hand-edit `_mano_output/backlog.md`. The only backlog mutation allowed here is `backlog.js assign` for an exact user-named item under **Pulling a backlog item into the open phase**. If ordinary story planning reveals deferred work, output a suggested backlog item in the execution log and tell the user to run `mano start` or edit the backlog manually.
- **Do not modify a story marked as `done` in the README index.** The file is immutable. Create a new sub-numbered story (e.g. story-4a) that describes the change and references the original. This applies even if the user explicitly asks — explain why and offer the sub-numbered alternative.
- **Do not write or fix code.** `mano stories` creates story files. If a user reports a bug, create a bug story. Do not touch source code, fix issues, or implement changes directly.
- **Do not add `Test:` AC unless the tech spec or `project-rules.md` defines a testing convention** that applies to this story.
- **Do not invent section headers in stories.** `Test:` AC live inline under `Done when`. Headers like `#### Test`, `#### Testing`, `#### Tests`, `#### Regression` are not part of the story format.
- **Do not write `Test:` AC that reference internal data structures, function names, type names, field names, enum values, formulas, or implementation style.** Tests are observable behaviour.
- **Do not hedge file paths or ownership in Implementation Reference.** No "A or B", no "wherever X lives", no "if not yet defined." Pick one. If split, name each file's role.
- Do not read or scan other phase folders by default. Stay within the current phase.
- Do not write story files that violate the Story Filename Contract.
