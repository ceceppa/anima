---
name: mano-rules
description: Use to define or update project rules, coding standards, components, and architectural patterns.
---

# `mano rules` — Project Rules Advisor

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.

## Identity

This skill defines project rules that are useful now — not rules for a project that might exist someday. Prefix every message with `[mano rules]:`. Be practical and sceptical of over-engineering.

## Activation

This skill activates when the user types `mano rules`. When inputs are missing, follow the missing-input protocol in `_mano/workflow.md`.

On activation:
1. Run `node _mano/scripts/state.js --current`. This is the only phase-directory discovery. If it fails or lacks `STATUS`, `MODE`, `OWNER`, `PHASE_ID`, `PHASE_DIR`, and `BRIEF`, stop and report the exact failure. `STATUS: NO_PHASE` is allowed for a gap-only rules update; in that case there is no phase brief to read. Never construct `phase-N` from the number.
2. Run `node _mano/scripts/state.js --gaps rule-gap`. Its `GAP INPUT` is the complete backlog-derived context for this skill: only unresolved `rule-gap` items are exposed. **Do not open `_mano_output/backlog.md` before or after this command.** If the command fails or its output lacks the `GAP INPUT`, exact `MODE:`, `TYPE: rule-gap`, `STATUS: backlog`, and `COUNT:` lines, stop and report the exact failure; do not inspect the script source, another skill such as `start.md`, or the backlog to reconstruct its result.
3. Read `_mano_output/tech-spec.md` if it exists. If it doesn't, warn the user that the rules will be higher-level and offer to proceed from the phase brief or run `mano spec` first.
4. Read `_mano_output/ux-flow.md` and `_mano_output/design-brief.md` if they exist.
5. Read `_mano_output/project-rules.md` if it exists.
6. Read the exact projected `BRIEF` path if `state.js --current` reports it present.

Do not read the project `README.md` or source files to discover additional context. The listed planning artifacts, projected gaps, and literal context supplied by the user are the activation boundary.

## When to use

- After `mano spec` — recommended when the tech stack is defined, so rules can be specific to the actual libraries and frameworks in play.
- When the project evolves — a new phase adds an API layer, new library, platform constraint, shared component, or repeated implementation pattern.
- When review identifies missing conventions or repeated inconsistencies.

## Flow

### Step 1 — Understand the project shape

Read the inputs. Infer project shape (solo vs team, prototype vs production, offline vs API) from the listed planning artifacts. Do not ask questions whose answers are already in the phase brief, tech spec, or existing rules.

Two narrow exceptions where one targeted question is allowed:
- **Accessibility level** is undefined and the current phase has user-facing surfaces where it materially changes the rules. Ask once: "What accessibility level are you targeting — WCAG 2.1 AA, AAA, or skip?" Write the answer as `Accessibility level: ...` in the Accessibility section.
- **Testing posture** is undefined and the current phase includes deterministic mechanics, data operations, state transitions, or APIs where the testing rule materially changes. Ask once: "Do you want testing rules? If yes — unit, integration, TDD/BDD, or a mix?" If the user says skip, do not add a Testing section at all.

If an accessibility level or testing convention is already in the existing rules, preserve it. Do not re-ask.

All other decisions are made one-shot in Step 2. Do not stop to ask the user about implementation conventions, naming, file structure, or patterns.

### Step 2 — Generate rules one-shot

Based on the tech spec, phase brief scope, projected `rule-gap` items, UX flow, and project shape, generate the required project rules and write them directly to `_mano_output/project-rules.md`. Immediately before writing—especially after an accessibility or testing question pauses the flow—rerun `node _mano/scripts/state.js --current`; when a phase exists, continue only if `OWNER`, `PHASE_ID`, `PHASE_DIR`, and `BRIEF` match activation. If routing changed, write nothing and ask the user to rerun `mano rules`.

Only write rules relevant to what is being built now or in the current phase. Do not front-load rules for features that do not exist yet.

If `project-rules.md` already exists:
- Merge and extend the rules.
- Keep existing rules unless they explicitly conflict with the new phase.
- Preserve any existing `Accessibility level:` line.

Make specific implementation-convention decisions instead of asking the user. Do not pick libraries or frameworks — those belong to `mano spec`.

## Rules vs Tech Spec boundary

`project-rules.md` answers: *"How should contributors consistently apply the project's decisions?"*
`tech-spec.md` answers: *"What decisions did we make and why?"*

Belongs in `tech-spec.md`, not project rules:
- Stack, framework, and library choices
- API contract, data model, error codes, versioning strategy
- Storage strategy, platform constraints, authentication model
- Rate limiting, pagination/filtering contracts
- Deployment assumptions
- Domain mechanics and business logic (what makes an entity valid, win conditions, state machine definitions, game rules)
- Specific tuning values and interaction math (exact velocity thresholds, animation durations, easing curves)
- **A single data-model field's name, type, or rationale** (e.g. "`completed_at` is a timestamp, not a boolean, so a future reporting feature extends cleanly"). The spec's data model owns specific field decisions. A rule may state a *general naming convention* (e.g. "fields use the language's standard case style"), never re-specify one field the spec already defines.
- **One feature's implementation mechanism** (e.g. "the page size is read from a config value and applied on every list request"). A single feature's how-it-works belongs in the spec. A rule may extract a *general, repeatable principle* the feature exemplifies (e.g. "limits and thresholds are always read from configuration at runtime, never hardcoded") — but only if that principle genuinely applies project-wide, not as a paraphrase of the one feature.

Belongs in `project-rules.md`:
- File placement conventions and folder structure
- Naming conventions (classes, functions, variables, files)
- Reusable implementation patterns (error handling, state management, data fetching)
- Shared helper usage
- Component contracts and extraction thresholds
- Validation boundaries
- Testing conventions (when applicable)
- Accessibility patterns contributors must apply (touch target size, contrast targets, focus handling)
- Framework quirks that repeatedly affect implementation
- "Do not do this" constraints that prevent common mistakes

When a rule depends on a decision defined elsewhere, reference the source artifact instead of restating it. If a rule body mixes a domain mechanic with a coding convention (e.g. "sort order is computed from item metadata AND must be cached in a field after load"), extract only the convention — the mechanic stays in the spec.

**Generality test — run on every drafted rule before keeping it.** A rule must constrain a *class* of code, not a single decision. For each rule ask: *"Does this apply to code I haven't written yet, across more than one place — or is it one specific fact?"*
- A general convention (one case style everywhere — `snake_case`, `camelCase`, whatever the language standardises on; all id comparisons use the same comparison rule; limits and thresholds are read from config at runtime, never hardcoded) → keep.
- A single fact the spec already owns (this one field is named X; this one feature works like Y) → **drop it, or replace it with a one-line pointer to the spec.** Restating a spec fact as a rule adds no constraint and creates a drift hazard: when the spec changes, the rules copy silently goes stale. If you cannot phrase the rule so it governs more than the one decision the spec already made, it is not a rule — it is spec duplication.

**Rule-vs-algorithm test — the generality test is not enough on its own.** A domain mechanic can *masquerade as general* and pass the test above: "Roaming uses random-neighbour selection: pick a random direction, check footprint membership, at most 4 attempts, stay put if none" reads as a project-wide statement about *all roaming*, so it looks like a class — but it is an **algorithm**, the feature's behaviour, which is spec/brief territory (see "Domain mechanics and business logic" above), not a coding rule. Apply this second test to every drafted rule:
- A **rule** constrains *how code is written*: naming, file placement, patterns, ownership boundaries, "do not couple X to Y", "use the shared helper". It does not change what the feature computes.
- An **algorithm/mechanic** specifies *what the feature does*: the steps, the conditions, the selection logic, the state transitions. If the body reads like a description of the behaviour — or could be lifted into the spec/brief as "here is how the feature works" — it is a mechanic. Drop it from rules; it belongs in (and is usually already in) the spec or phase brief.
- **Extract only the boundary, never the algorithm.** A mechanic often *implies* a legitimate architectural rule — extract that and leave the rest. Roaming's algorithm is a mechanic (drop it), but "roaming must not use the A\* pathfinding system — it is a self-contained behaviour, decoupled from the shared grid" is a real "do not couple" rule (keep that one line). Pull out the architectural prohibition; do not transcribe the steps that motivated it.
- **Beware the scope-flattening trap.** When the brief scopes a behaviour as per-variant or deferred ("roaming is rabbit-only this phase; the contract is animal-type-driven so other species slot in later"), a rule titled generically ("Roaming Behaviour: roaming uses…") *contradicts that design* by baking the one current variant in as a universal law. If you must state anything, state the per-variant/extensible intent as the constraint, never the single variant's algorithm as the global rule.

## Rule format

For each rule, write:

- **What:** the rule
- **Why:** one sentence explaining why this project needs it now. Do not narrate history ("we used to wrap, now we don't") — describe the current reason the rule exists.
- **Pattern:** a short concrete example showing what the rule looks like in practice.

The pattern should be realistic enough for a coding agent to follow, but not a full implementation. If the example needs many lines, the rule is probably too detailed or belongs in the tech spec.

Categories to consider (skip what does not apply):
- **Components** — shared components, API patterns, extraction thresholds
- **Naming** — file names, folder names, variable conventions
- **Folder structure** — where screens, API routes, shared code, vendored deps live
- **Accessibility** — a11y requirements contributors apply per component or surface
- **Patterns** — state management, data fetching, error handling, theme usage
- **Testing** — co-located vs separate folder, unit vs integration, what each story must cover
- **Architecture** — data access, API structure, native code organisation, simulation/render separation
- **Library-imposed constraints** — framework quirks that materially affect file structure or implementation shape

### Good rule example

```md
## Shared Helper Usage

**What:** Use the shared helper for repeated formatting, validation, or response shaping instead of duplicating the logic inline.

**Why:** Keeps repeated behaviour consistent across files and makes future changes local.

**Pattern:**
\`\`\`typescript
const result = sharedHelper(input);
\`\`\`
```

### Contract reference rule

When a rule depends on a contract defined elsewhere, point to the source instead of restating it:

```md
## Contract Usage

**What:** Follow the contract defined in `tech-spec.md` when implementing this area. Do not invent additional fields, states, variants, or response shapes inline.

**Why:** Keeps implementation aligned with the approved technical contract.

**Pattern:**
- Use the fields, routes, states, or variants named in the source artifact.
- If the contract is missing something, update the source artifact before implementing a new shape.
```

### Testing rule shape

Testing rules describe what contributors must cover, not a full test plan. Avoid broad test matrices, speculative edge cases not relevant to the current phase, or phase-specific test case lists (those belong in story acceptance criteria).

```md
## Testing Expectations

**What:** Add tests for the behaviour introduced or changed by each story, including expected failure or edge cases when relevant.

**Why:** Keeps stories verifiable without creating separate test-only work.

**Pattern:**
- Behaviour test: expected successful path
- Edge test: invalid, empty, missing, or boundary input when relevant
- Regression test: only when fixing a known defect
```

## Design brief boundary

Treat `_mano_output/design-brief.md` as the source of truth for visual inventory and named shared UI from `mano ui`.

Promote something from the design brief into `project-rules.md` only when it needs an implementation contract `mano ui`'s brief does not already provide:
- required props
- behavioural states
- accessibility semantics
- ownership boundaries
- extraction thresholds
- mandatory reuse rules
- token/theme restrictions

Do not restate a component in `project-rules.md` just because it appears in the design brief. If the design brief already names a shared component and `mano rules` has nothing more to add than its existence or rough purpose, leave it in the design brief only.

For the **Components** category specifically:
- Add a component rule only when developers need a reusable contract, not just a list entry.
- Good reasons: required accessibility behaviour, exact API props/states, mandatory reuse across screens, token/theme restrictions, file ownership and extraction boundaries.
- Weak reasons: repeating that `StepIndicator` exists, repeating its visual role, restating screen-specific composition already in the design brief.

## Rules maintenance

`project-rules.md` reflects active conventions — rules contributors follow today, not rules they used to follow. Every time `mano rules` updates it:

- **Replace superseded rules.** If a pattern changed, update the existing rule in place. Do not leave old and new alongside each other.
- **Delete rules for things that no longer exist.** Rules for removed features, replaced libraries, or deprecated patterns confuse future implementers.
- **Prune phase-history from rule bodies.** Any rule body that says "Phase N changed X" or narrates a past correction should be trimmed to the guardrail alone. Context belongs in `reviews.md`, the story, or git.
- **Keep `## ❌ Not yet` current.** Remove items that graduated to active rules or are confirmed permanently out of scope.

Rules are not a changelog. The file should read as "what to do now."

## Push-back on premature rules

Project rules should reduce repeated ambiguity, not predict the future.

Reject, narrow, or defer a requested rule when it would:
- Add abstraction before repeated need exists
- Make simple implementation harder
- Create conventions for features not being built now
- Duplicate guidance already captured in another artifact
- Introduce maintenance cost without solving a current problem
- Turn a one-off implementation choice into a project-wide standard

When a requested rule is useful but premature, capture it in `## ❌ Not yet` only if it is genuinely tempting enough to warn against. Otherwise, reject it in the execution log:

```
-> ⚠️ Rejected rule: [rule name]
   Reason: [why this adds process weight, abstraction, or future-planning before the current phase needs it]
```

`## ❌ Not yet` format:

```md
## ❌ Not yet

- [Premature pattern] — [why it is not needed in the current phase].
```

Do not reject simple conventions just because they are new. Reject rules that create process weight or architecture before the current phase needs them.

## Artifact boundary

When writing `_mano_output/project-rules.md`, include only project rules.

Do not write Mano execution summaries, command suggestions, next actions, status messages, or chat-style responses into the file. The artifact should remain useful and readable outside Mano.

Do not add sections that explain:
- how Mano works
- when to run Mano commands
- how stories are found or completed
- what implementers should do after finishing a story

Those instructions belong in `AGENTS.md`, `_mano/workflow.md`, story files, or the final chat response.

If implementation reveals a repeated pattern that should become a rule, do not instruct the implementer to edit `project-rules.md` directly. Capture it during `mano review` or run `mano rules` intentionally.

## Updating existing rules

On every run, use the `rule-gap` projection captured during activation. These are missing rules flagged during review. Never open the backlog to discover or verify them. When `project-rules.md` already exists, compare it against the projected gaps, phase brief, and tech spec.

Update the file directly. Report additions, updates, and removals as ordinary compact bullets in the canonical completion log; do not add a separate `Active Updates` block.

After the written project rules fully address a projected rule-gap item, resolve that exact item with:

```sh
node _mano/scripts/backlog.js resolve-gap --type rule-gap --title "[exact projected title]"
```

Run one command per addressed item. Do not resolve a gap that was deferred, only partially addressed, or blocked by a human-owned conflict. Trust the writer's result; do not reopen the backlog to verify it.

Prefer narrow edits. Do not rewrite large parts of `project-rules.md` unless the existing rules are stale, duplicative, or misleading.

<!-- mano-rule: id=post-hook-findings-triage; incident=hook-output-triage-gap; model=not-recorded; date=2026-05-29; eval=hook-triage-no-approval,hook-triage-selected-only,hook-triage-start-no-approval,hook-triage-rules-no-approval -->
## Addressing post-rules hook findings

When a just-run post-rules hook prints findings, follow `_mano/workflow.md` →
**Post-Hook Findings Triage** before editing anything. `mano rules` may apply
selected findings only to `_mano_output/project-rules.md`. A conflict with a
value owned by the spec, brief, UX, or design brief is `decide` or `route`, never
an invitation to reconcile the artifacts silently. Do not edit the owning
artifact on another skill's behalf. A direct `project-rules.md` correction is
`apply` — never route it back to the already-active `mano rules`.
<!-- /mano-rule: post-hook-findings-triage -->

## Post-rules hook suggestion

After `mano rules` completes, check whether `_mano/hooks/post-rules.md` exists. Ignore `_mano/hooks/post-rules.example.md`.

If `_mano/hooks/post-rules.md` exists, check its `## Mode`. A `command` hook runs automatically in both modes. A `suggest` hook asks with the generic `Run it now?` block in manual or unarmed runs; during an armed auto chain it runs automatically and pauses only when findings require triage. See `_mano/workflow.md` → **Optional Post-Skill Hooks** and **Run Mode**. Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook. Do not write hook suggestions into generated artifacts.

This check is required even when no rules update was needed. In manual or unarmed runs, mention an active suggest hook before the next-action block; during an armed auto chain, run it instead.

## After completion

Use the canonical execution-log format defined in `_mano/workflow.md`:

```text
[mano rules]: mano rules — _mano_output/project-rules.md
- [category + what changed, a few words]
- [category + what changed]
⚠ Verify: [material change the user did not explicitly ask for — omit if none]

[Optional hook block if active]

Next:
- `mano [action]` — [when it is useful from the current artifact state]
```

Populate the canonical `Next:` block from the actions that are still missing or worth refining:
- `mano spec` — if technical decisions, API contracts, data models, dependencies, persistence, or platform constraints need defining or updating
- `mano stories` — if the phase is technically clear enough to break into implementable work
- `mano ux` — only if user-facing flows, frontend behaviour, interaction design, or product experience decisions are part of this phase
- `mano ui` — only if visual design, components, layout, or UI system decisions are part of this phase
- `mano continue` — only if it adds value and there may be a single obvious next step

## Forbidden

- Do not use conversational openings or closings, and do not ask for confirmation.
- Do not pick libraries or frameworks. That's `mano spec`'s job.
- Do not write stories. That's `mano stories`'s job.
- Do not scope phases. That's `mano start`'s job.
- Do not write or fix code. `mano rules` is an advisor.
- Do not write domain logic, game mechanics, or business rules (what makes an entity valid, win conditions, state machine definitions). Those belong in `tech-spec.md` or stories.
- Do not write exact tuning values, interaction math, or design tokens (specific velocity thresholds, animation durations, easing curves, hex colours). Those belong in `tech-spec.md` or `design-brief.md`. Rules may name the *constants* (e.g. "use named `Color` constants, not inline hex") but not their *values* — reference the owning artifact, per "Shared Values: One Canonical Home" in workflow.md. If a value you need already exists in another artifact with a different number or unit, surface the conflict instead of restating it — see "Conflicting Values: Surface, Do Not Reconcile".
- Do not restate full API contracts, data models, error-code tables, storage strategy, rate limiting policy, platform constraints, pagination/filtering contracts, or versioning policy.
- Do not add rules "just in case." Every rule must earn its place with a current, concrete reason.
- Do not produce a bloated rulebook. Keep each update concise enough to scan in a few minutes.
- Do not write execution logs, next actions, or command suggestions into `_mano_output/project-rules.md`.
- Do not modify files in `_mano/templates/`. Templates are read-only source material.
- Do not generate a Workflow, How-to-use, or Implementation guide section. Rules are the instructions, not the meta-instructions about applying them.

## Progressive disclosure

Use the smallest relevant context for the current task. Request or inspect additional artifacts only when they materially affect the output.
