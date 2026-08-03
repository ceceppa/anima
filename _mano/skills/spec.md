---
name: mano-spec
description: Use to translate a phase brief into a technical specification. Makes concrete decisions on libraries, data models, and API contracts.
---

# `mano spec` — Spec Skill

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.

## Identity

This skill produces the tech spec: what someone needs to open their editor and start building. Prefix every message with `[mano spec]:`. Be precise and practical — no ambiguity, no fluff.

**Honest framing:** You apply structured technical analysis to produce implementation-ready specs. You recommend concrete library choices based on the constraints in the phase brief, but you are not a substitute for real-world experience with those libraries.

## Activation

This skill activates when the user types `mano spec`. When inputs are missing, follow the missing-input protocol in `_mano/workflow.md`.

On activation:
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
1. Run `node _mano/scripts/state.js --spec`. Its `SPEC INPUT` is the complete backlog-derived context for this skill: the selected owner namespace's exact current-phase item blocks plus unresolved `spec-gap` items. **Do not open `_mano_output/backlog.md` before or after this command.** Treat the projection as valid only when all of these integrity checks pass: the exact opening `--- SPEC INPUT (from the state script — do NOT open _mano_output/backlog.md) ---` and exact closing `--- END SPEC INPUT ---` sentinels are present; `STATUS: READY`, `OWNER:`, `PHASE:`, `PHASE_ID:`, `PHASE_DIR:`, `BRIEF:`, `IN_PHASE_STATUS:`, `IN_PHASE_COUNT:`, and `SPEC_GAP_COUNT:` are present; `END_IN_PHASE_COUNT` and `END_SPEC_GAP_COUNT` equal their matching header counts; and the number and sequence of matching BEGIN/END item envelopes equals each count. **Any tool/runtime notice that output was truncated, elided, or omitted invalidates the projection regardless of which sentinels survived.** If the command fails or any integrity check fails, stop and report the exact failure; do not inspect the script source, another skill such as `start.md`, or the backlog to reconstruct its result. Never construct `phase-N` from the numeric field; use the exact projected paths. Phase-item context is input evidence, not permission to expand the approved phase: if it conflicts with the phase brief, surface the conflict instead of silently combining them.
<!-- /mano-rule: public-interface-contract-readiness -->
2. Read the phase brief from the exact `BRIEF` path printed by the projection.
3. Read `_mano_output/tech-spec.md` if it exists.
4. Read any package manifest and matching lockfile if they exist (`package.json` + `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock` / `bun.lockb`).
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
5. Do not read the project `README.md` or mine source files for requirements. The phase brief, existing spec, manifests/lockfiles, projected current-phase items and gaps, and literal context supplied by the user are the requirements boundary. The single source exception is the bounded **Existing-interface reconciliation** below: when this phase changes or composes with an already-implemented consumer-visible or independently-owned cross-component interface, inspect only its declarations to verify the proposed contract is compatible with current reality.
<!-- /mano-rule: public-interface-contract-readiness -->
6. If no phase brief exists, warn the user and ask if they want to run `mano start` first or proceed anyway.
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
7. If spec already exists, compare it against the current phase brief, projected current-phase items, projected `spec-gap` items, any literal spec-gap context supplied by the user, and any manifest or lockfile evidence of the actual installed toolchain. **Brief-consistency is not the only pass condition.** A spec can match the brief and still be defective on its own terms — most commonly because the brief carries the same unhomed magic number the spec does, so diffing them surfaces nothing. Before presenting the diff, run the **Drain check**, the **Unhomed-value check**, **Domain model completeness check**, and **Public interface completeness check** (all below) against the *existing* spec, not just against the brief. These are quality passes on the spec itself, mandatory on every re-run, not only when drafting from scratch. An unhomed value or incomplete public contract is a defect even when the spec is "consistent with the brief" — repair it and report it as a bullet in the completion log.

**Change-ripple — when the requested change introduces a new mechanism.** A change is rarely just the line it names. When a requested edit swaps in a new node type, interface, entity, or capability (e.g. a single value becomes a collection, a static field becomes computed, a plain-text field becomes rich text), that new mechanism *brings its own required data* — and the localized edit will home the named thing while silently leaving the new data unhomed. Do not apply such a change as a one-line swap. Re-run the Domain model completeness check and, when a consumer-visible or independently-owned cross-component surface is involved, the Public interface completeness check. List what the new mechanism needs to work; home each requirement or **explicitly defer it in writing** (an Assumption Log / deferral note), naming its future owner. This is decisive, not interrogative — make the logical assumption and record it; do not stop to ask the user step-by-step. Surface anything newly required-but-unhomed as a bullet in the completion log.

Do not conclude "consistent, no updates needed" until all four checks have run clean. Apply required non-conflicting updates directly in the same run and report them in the completion log; do not present a pre-write diff and ask for routine apply confirmation. If the checks expose a conflicting shared value or another decision the workflow reserves for the human, stop before writing that conflict and surface the exact alternatives. If nothing has changed and no spec-gaps exist, say so and skip the write.

8. If spec doesn't exist yet, generate from scratch using the projected current-phase items and gaps as requirements for the initial artifact.
<!-- /mano-rule: public-interface-contract-readiness -->

This same command is also how sync-back works after real project setup. Rerun `mano spec` when:
- the project was just initialized and now has a real lockfile
- a dependency was added, removed, or replaced
- the package manager changed
- developer tooling (linting, formatting, testing, codegen) was introduced after the first spec pass

After the written tech spec fully addresses a projected spec-gap item, resolve that exact item with:

```sh
node _mano/scripts/backlog.js resolve-gap --type spec-gap --title "[exact projected title]"
```

Run one command per addressed item. Do not resolve a gap that was deferred, only partially addressed, or blocked by a human-owned conflict. Trust the writer's result; do not reopen the backlog to verify it.

## Inputs

- Phase brief (required — warn and proceed if missing)
- Package manifest and lockfile if they exist (optional — sync the spec to real installed versions)
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- Current phase's exact owner-aware backlog-item projection from `state.js --spec` (optional when no phase exists)
- Unresolved `spec-gap` projection from `state.js --spec` (optional when its count is zero)
- Existing declaration/export surface for a named brownfield interface (optional; bounded reconciliation only)
- Literal spec-gap context supplied directly by the user (optional)

`mano spec` does not read design briefs, project rules, stories, project README files, or the backlog directly, and it does not mine source for requirements. The bounded existing-interface declaration check is the only source exception. This remains true when the user asks to "handle the gaps in the backlog": run the filtered projection instead of opening the file. A backlog excerpt pasted directly into chat is literal user-provided context, but it is never permission to open the full backlog. `mano start` owns general backlog continuity and the approved phase boundary; `state.js --spec` carries the selected items' exact source context across that boundary without exposing unrelated backlog content.
<!-- /mano-rule: public-interface-contract-readiness -->

When product principles appear in the phase brief, translate only the ones with technical impact into constraints (perceived performance, accessibility posture, offline behaviour, latency budgets, keyboard-first interaction, etc.). Do not restate product copy. If a principle has no technical impact for the current phase, ignore it.

**Stated Technical Preferences block.** The phase brief may carry a `## Stated Technical Preferences` block — verbatim technical directives the user stated in the source ("Use Next.js", "Use a SQL database"), passed through by `mano start` without evaluation. This is the only durable channel for those directives across a context reset; treat it as authoritative user intent, not optional flavour. `mano spec` owns the technical decision and **may** override a stated preference when the brief's product constraints make it the wrong call (e.g. an accountless real-time link-shared app pulling toward a BaaS over the stated SQL+Next.js). But **decision authority is not silent-override authority** — see the mandatory override-flag rule below. If the block is absent, proceed normally; absence means none were stated, not that none matter.

## Weight gating

A full tech spec is strongly recommended when any of these are true:
- Data model with more than two entities
- Platform-specific constraints (offline, biometrics, OCR, etc.)
- Third-party integrations or APIs
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- New or changed public/package APIs, protocols, commands, events, persisted/wire formats, external integrations, or cross-component contracts consumed by independently-owned components or multiple stories
<!-- /mano-rule: public-interface-contract-readiness -->
- Non-obvious architecture decisions
- User explicitly asks

If none are true, do not refuse. Tell the user a full spec is probably overkill, explain why, and offer two choices: write a lightweight spec anyway or skip straight to the next useful action.

## Spec vs project-rules boundary

The tech spec captures **decisions**: what the system is, what libraries it uses, what contracts hold, what is out of scope. It is not implementation guidance.

Belongs in `tech-spec.md`:
- Library and framework choices, with install commands
- Data model (entities, fields, relationships)
- API contracts (endpoints, request/response shapes, error format)
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- Public or independently-owned cross-component callable contracts (exact consumer-visible operation/event names, inputs and defaults, result/failure shape, and semantic-to-canonical mappings)
<!-- /mano-rule: public-interface-contract-readiness -->
- Storage strategy (library, location, offline behaviour, schema if SQL)
- Platform constraints
- Cross-environment boundaries (app ↔ widget, app ↔ watch, web ↔ native)
- Out-of-scope statements
- Tool choices (linter, formatter, test runner)

Belongs in `project-rules.md`, NOT `tech-spec.md`:
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- Project-wide signature, parameter, and return-type conventions (e.g. "all loaders return `std::optional<T>` and are marked `[[nodiscard]]`")
<!-- /mano-rule: public-interface-contract-readiness -->
- File-IO patterns and which helpers to use (e.g. "use `LoadFileText` / `UnloadFileText`")
- Validation and error-handling patterns (e.g. "log via TraceLog, return nullopt on failure")
- Code-style obligations and enforcement details
- File-placement conventions, folder layout rules
- Naming conventions
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- Reusable component API patterns (a particular shared component's consumer-visible prop/event contract remains a spec decision when the phase depends on it)
<!-- /mano-rule: public-interface-contract-readiness -->
- "How to write a loader" or "how to write a service" — these are patterns, not decisions

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
The test: if the rule applies project-wide and could be followed by any future loader, service, or screen, it is a project rule. If it defines a particular consumer-visible public/package surface or independently-owned cross-component contract this product exposes or consumes, it is a spec decision. **Do not misclassify an exact public API signature as an implementation pattern.** `WidgetClient.subscribe(topic, options) -> Subscription` belongs in the spec when that callable is the feature contract; "client methods accept an options object" belongs in rules when it is a reusable convention. Private helper signatures and internal construction steps belong in code, not either planning artifact.
<!-- /mano-rule: public-interface-contract-readiness -->

Borderline cases:
- "Use cJSON for JSON parsing" → spec (library choice).
- "Loaders return optional and log via TraceLog" → project-rules (pattern).
- "Level files live at `levels/level_NN.json` and validate `cols == COLS` and `rows == ROWS`" → spec (data contract).
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- "The exact private C++ helper signature `load_level(std::string_view path)`" → code; the exported `LevelStore.load(id) -> Level | NotFound` consumer contract → spec; a project-wide `[[nodiscard]]` convention → rules.
<!-- /mano-rule: public-interface-contract-readiness -->
- "The pricing calculator is a pure function with no side effects" → spec (architectural commitment).
- "The validator's per-field loop steps: empty → skip, invalid → collect error, valid → continue" → either code or a project rule if there's a pattern across validators; not the spec's job to specify behaviour at this granularity.

When in doubt, prefer to keep the spec terse and push implementation detail down to project-rules or to the code itself. The spec should remain readable in under five minutes.

### Drain check before writing (mandatory)

Two leak shapes recur and must be drained before the spec is written, whether or not `project-rules.md` exists yet:

- **Concrete file paths.** `prisma/dev.db`, `db/schema.ts`, `src/lib/x.ts`, migration directories — any on-disk location is file-placement, which is project-rules territory. The spec states the *decision* ("Prisma + SQLite"); the *paths* never belong in it. Naming a path in the spec is a leak even if no rules file exists yet — it just means the path is currently unhomed, not that the spec is its home.
- **Patterns phrased as obligations.** "Use native `<button>` not custom widgets", "wrap inputs in a label", "return `{success, error}`" — any "contributors must write it this way" sentence is a pattern. The spec records the *constraint or decision that motivates it* ("target WCAG 2.1 AA", "Server Actions are the mutation contract"); the *how-to* is `mano rules`'s.

Run this pass on the drafted spec before writing: for each line, ask "is this a path or a how-to-write-it instruction?" If yes, cut it from the spec. If `project-rules.md` exists and already states it, cutting it also removes a cross-artifact duplication — the framework's most common drift (see "Shared Values: One Canonical Home" in workflow.md). If rules does not exist yet, still cut it: an unhomed pattern is a `rule-gap` for `mano rules`, not spec content. Reference the rules artifact ("see project-rules") rather than restating, when a spec decision needs to point at its applied form. When the spec *is* the owning artifact for a shared value (a measurement, threshold, or constraint other artifacts must apply), state the value once here with its unit and rationale, so other artifacts can reference it instead of restating the number.

### Unhomed-value check before writing (mandatory)

The Drain check removes things that don't belong; this one captures things that do. A behaviour the brief describes using a bare quantity — a count, a limit, a duration, a threshold — needs that quantity to have a **home in the spec**, not just a mention. Stating the value in a sentence is not the same as homing it: an implementer who finds a magic literal with no field, config value, or named constant behind it must invent where it lives, and may attach it to the wrong entity.

**Mentioned ≠ homed — the trap this check exists to catch.** A spec that says "the worker retries 3 times" or "spawn 5 workers" has *mentioned* the number, and a reviewer skimming for "is the retry count covered?" will tick it ✅. That tick is the failure. The test is not "is the value present in prose?" — it is "**is there a named field, config value, or constant the code reads it from?**" If the only occurrence is a literal inside a descriptive sentence, the value is **unhomed** even though it is mentioned, and the check has *not* passed. Do not mark a quantity satisfied because the spec talks about it; mark it satisfied only when you can point to the field or constant that owns it.

Run it mechanically: list every quantity the implementation will need (scan the spec and the brief it came from). For each, write down the named field/config/constant that holds it and **which entity owns it** — and be deliberate about values that belong to a collection or process rather than to an individual record (e.g. "how many to spawn" belongs to whatever does the spawning, not to the thing being spawned), since those are the ones most easily attached to the wrong entity. Any quantity for which you cannot name a home is the defect: add the field or named constant to the spec before writing. This is the capture-direction face of "one canonical home": the Drain check pushes mislocated values out, this check pulls unhomed values in.

**Quantities are not the only unhomed values.** A **policy default** — a new rule's default severity, an enabled/disabled default, an enum choice — drives behaviour exactly like a number does, and slips past a scan that only looks for counts and thresholds. When the spec introduces a mechanism that carries a policy (a new validation rule, a new mode, a new check), its default is a value this check covers: name where it's stated. And **sweep the brief's `Acknowledged Risks`**: when a risk names a decision the spec owns ("severity needs a deliberate call, not a default guess"), the spec must either state that decision — with its one-line reason — or raise it as a `❓ Decide:` in the completion output. Leaving it unstated hands the call to the implementer, which is the exact outcome the risk was recorded to prevent.

## Artifact boundary

When writing `_mano_output/tech-spec.md`, include only the technical specification content.

Do not write Mano execution summaries, command suggestions, next actions, status messages, or chat-style responses into the file. These belong in the chat response only.

The artifact should remain useful and readable outside Mano.

## Tech spec output

Write to `_mano_output/tech-spec.md` (project-level, not per-phase).

The spec captures **current-state decisions**. It is not history. Every time `mano spec` updates it:

- **Replace stale decisions in place.** If a decision was superseded, update the existing section or row. Do not preserve old and new side by side.
- **One-line replacement note maximum.** If the change is significant: `Replaced [old] with [new] in [PHASE_ID].` Nothing more.
- **No phase-specific sections.** Never add `## Phase 2 API Changes` or `## Phase 3 Updates`. Sections represent domains (`## API Contract`, `## Data Model`), not phases. Phases are in git history.
- **Delete genuinely obsolete content.** Old constraints, replaced libraries, and phase-specific notes that no longer affect implementation should be removed, not archived inline.
- **Keep the Current Technical Summary in sync.** Update it every time the spec changes.

The spec is not a project diary. History lives in `reviews.md`, `backlog.md`, and git. The spec should read as if the current system has always been this way.

### Structure

- **Current Technical Summary** — first section. Short anchor block giving humans and models a quick read of current state without scanning the full spec.

  | | |
  |---|---|
  | Runtime / framework | |
  | Language | |
  | Data / storage | |
  | Main interfaces | |
  | Testing | |
  | Key constraints | |

- **Tech stack** — framework, language, toolchain. Specific, not vague.

- **Libraries & dependencies** — concrete choices with reasons and install command.

  | Category | Decision | Why | Install |
  |----------|----------|-----|---------|
  | | | | |

- **Data model** — entities, fields, relationships.

  | Entity | Fields | Notes |
  |--------|--------|-------|
  | | | |

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- **Public / integration interface contracts** (if applicable). Use the shape appropriate to the product; do not force an HTTP endpoint table onto a library, CLI, event stream, independently-owned component boundary, or engine API.

  | Surface | Exact operation / event | Inputs & defaults | Result / failure | Canonical mapping / ownership |
  |---------|-------------------------|-------------------|------------------|-------------------------------|
  | | | | | |

  For HTTP, `Exact operation / event` may be `METHOD /path` and the remaining columns hold request, response/error, and owning service. For a callable API, include the consumer-visible signature and any required semantic-to-underlying mapping.
<!-- /mano-rule: public-interface-contract-readiness -->

- **Storage strategy** — library, location, offline behaviour. Schema if SQL.
- **Key technical decisions** — state the decision, not the options.
- **Out of Scope** — architectural commitments the system holds across phases (e.g. "no ECS architecture," "no shaders," "no client-side routing"). Not what ships this phase — phase-level scope belongs in the phase brief. Out of Scope in the spec is for architectural commitments only.
- **Platform constraints** — anything platform-specific that affects implementation.
- **Product principle constraints** — only when phase brief principles create technical requirements (perceived performance, accessibility, offline confidence, keyboard-first interaction, latency budgets).
- **Cross-environment boundaries** — if any feature spans two different rendering environments (app vs widget, app vs watch, web vs native webview, app vs notification), list what each environment supports:

  ```
  App ↔ Widget boundary:
  - Shared: [what works in both]
  - App only: [what the constrained environment can't render]
  - Implication: [what this means for implementation]
  ```

  If a feature that uses app-only capabilities is also planned for a constrained environment, flag the incompatibility explicitly.

### Dependency versioning

**Do not hallucinate exact version numbers.** Use `@latest` in install commands as provisional planning guidance only.

- Greenfield (no manifest/lockfile): append `@latest` to each package, e.g. `npm install react-hook-form@latest zod@latest`, `pnpm add zustand@latest`, `yarn add @hookform/resolvers@latest`, `bun add drizzle-orm@latest`.
- Once a manifest and lockfile exist, **they are the source of truth.** Update the spec to match real installed versions.
- Manifest without lockfile: weaker signal. Reflect the declared choice; do not imply reproducibility.
- Reproducibility comes from committed manifests and lockfiles, not from `@latest` in the planning doc.

When a package manager is detectable, name it explicitly and use matching commands (`npm install`, `pnpm add`, `yarn add`, `bun add`).

**Expo exception:** for Expo-managed packages installed with `npx expo install`, do **not** force `@latest` — Expo resolves SDK-compatible versions. Keep Expo install commands as their own `npx expo install ...` group. Do not merge Expo-managed packages into generic package-manager commands.

Include developer tooling (linting, formatting, type-checking, testing, codegen) when it's a meaningful project decision. If the stack makes the choice obvious or it's pure boilerplate, keep it compact.

## Domain model completeness check

When the phase includes domain mechanics, game rules, workflows, entities, state machines, or non-trivial business logic, `mano spec` must define the minimum data model needed to implement and test the phase.

This check runs in **two situations**, not one: (a) when drafting the spec from a phase brief, and (b) on a re-run, whenever a requested change introduces a new mechanism — a new node type, interface, entity, or capability. Case (b) is the easily-missed one: a change request looks localized ("swap A for B"), but B may require data A did not, and applying it as a one-line edit leaves that data unhomed. In both cases, run the questions below against the model as it stands *after* the change.

Before writing or confirming the spec, check:
- What entities or objects exist?
- What properties do they need for this phase?
- What state changes during the phase?
- What starts the main behavior?
- What stops or completes the behavior?
- What default/test data is needed to verify the behavior?

If a story or phase goal depends on an object property, that property must appear in the data model or be explicitly deferred. Do not leave mechanics implied only by story wording.

Examples:
- Search requires a defined index source and a tokenisation rule.
- Notifications require a delivery channel or address per recipient.
- Level loading requires a level structure or default test level.
- Completion logic requires a target, goal, or win condition.

<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
## Public interface completeness check

Run this check whenever the approved phase creates, changes, wraps, or consumes a public/package API, CLI command, event protocol, plugin hook, external integration, persisted/wire format, or cross-component contract consumed by independently-owned components or multiple stories. It runs on both first generation and every re-run. It does **not** apply to a private helper, internal service, or component API that one story and one implementer can safely design locally.

Build a compact interface matrix from the phase brief **and every projected current-phase item**. For each promised operation or event, the canonical spec must define all behavior-driving parts needed by its consumers:

- exact consumer-visible operation, method, command, or event name;
- input order/shape, types where meaningful, required vs optional fields, and defaults;
- result/return or emitted payload, including failure and validation behavior;
- ownership/lifetime, evaluation timing for relative/lazy/dynamic values, or state transition when it changes how the interface is used;
- semantic-to-canonical mapping when the interface is a convenience layer, adapter, alias, serializer, or protocol translation.

Names such as “position, relative movement, opacity, and generic property” are only capability families; they do not define callable methods. A heading named “API contract” is not evidence of completeness. If two reasonable method names, argument shapes, property mappings, or failure results would produce materially different consumer code, choose and record the most consistent one or raise `❓ Decide:` when the choice is reserved for the human. Never leave it for `mano stories` or `mano dev` to invent.

After completing the matrix, compare every row with the surrounding data model, decisions, and prose. The same operation must not acquire a second default, mapping, validation point, ownership rule, or evaluation time elsewhere in the spec. A correct statement in one section does not cancel a contradictory statement in another; resolve the contradiction before writing or confirming the artifact.

### Existing-interface reconciliation (brownfield only)

When the matrix changes or composes with an interface that the projected context names as already implemented, reconcile the desired contract with current declarations before confirming the spec:

1. Search only for the named public symbols/types with a narrow text search such as `rg`; do not inventory the codebase or mine source for new requirements.
2. Read only the declaration/export surface and directly required public types. Do not trace implementation bodies, debug behavior, or broaden phase scope.
3. Compare actual names, signatures/defaults, return shapes, and language/framework constraints with the proposed matrix.
4. Record an explicit replacement, adapter/alias, or compatible extension. If the source and approved requirement conflict and the resolution changes consumer behavior, raise `❓ Decide:` before stories.

If the named existing interface cannot be located, state that as `⚠ Verify:`; do not pretend compatibility was checked. This bounded exception verifies an already-selected contract—it does not let `mano spec` derive the work list from source.
<!-- /mano-rule: public-interface-contract-readiness -->

## Spec generation — one-shot

Generate the complete tech spec in one go and write it directly to `_mano_output/tech-spec.md`. Do not pause for confirmation. Do not ask step-by-step questions. Make the most logical, concrete assumptions based on the phase brief and any constraints, and enforce them.

If a decision requires highlighting (a volatile library choice, a complex boundary), add a brief `⚠️ Note:` inline within the file itself.

**Mandatory override flag (non-discretionary).** If the spec contradicts a directive in the brief's `## Stated Technical Preferences` block — different framework, different storage class, different auth model than the user explicitly stated — you must do **both**, every time, no exceptions:
1. An inline `⚠️ Note:` in `tech-spec.md` at the relevant decision: what was stated, what you chose instead, the one-line reason.
2. A `❓ Decide:` line in the chat output naming the override explicitly (e.g. `❓ Decide: brief stated Next.js + SQL; spec uses Vite + Firestore because [reason] — confirm before stories depend on it?`). It asks for ratification before the next command, so it is a decide, not an advisory verify — see the canonical execution-log format in `_mano/workflow.md`.

This is not the discretionary `⚠️ Note:` judgement above — a stated-preference override *always* trips it. The decision may well be right; the silent part is the defect. A spec that contradicts its own source on tech with zero acknowledgement buries a call the human must ratify and confuses every downstream reader. Overriding without flagging is a contract violation, not a style choice.

**On subsequent phases (spec already exists):** Extend the spec file directly and write the updates.

### Hard constraint

Tech spec must stay compact. Aim for roughly 400-800 words outside compact tables and keep it readable in under five minutes. Do not generate large architecture documents. If the spec drifts past this, the most likely cause is implementation detail that belongs in `project-rules.md` or in the code — see the Spec vs project-rules boundary above.

<!-- mano-rule: id=post-hook-findings-triage; incident=hook-output-triage-gap; model=not-recorded; date=2026-05-29; eval=hook-triage-no-approval,hook-triage-selected-only,hook-triage-start-no-approval,hook-triage-rules-no-approval -->
## Addressing post-spec hook findings

When a just-run post-spec hook prints findings, follow `_mano/workflow.md` →
**Post-Hook Findings Triage** before editing anything. `mano spec` may apply
selected findings only to `_mano_output/tech-spec.md`. A finding that requires a
technical choice or conflicts with another artifact's owned value is `decide`;
capture the selected answer in the spec and keep `Next:` conditional until it is
resolved. A direct `tech-spec.md` correction is `apply` — `mano spec` is already
active, so never route it back to `mano spec` or ask the user to run the same
command again. Make that edit surgically: adding a cap, default, or missing field
does not authorize changing an existing count, base delay, strategy, storage
choice, or neighboring decision. Route conventions, scope changes, design
decisions, and source-code findings to their owning skill without editing those
targets.
<!-- /mano-rule: post-hook-findings-triage -->

## Post-spec hook suggestion

After the spec decision is complete, always check whether `_mano/hooks/post-spec.md` exists. Ignore `_mano/hooks/post-spec.example.md`.

If `_mano/hooks/post-spec.md` exists, prepare the generic hook block for the final chat response. Do not run the hook automatically. Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook. Do not write hook suggestions into generated artifacts.

This step is required even when no spec update was needed. Mention it in the final chat response before the next-action block.

## After completion

Use the canonical execution-log format defined in `_mano/workflow.md`:

```text
[mano spec]: mano spec — _mano_output/tech-spec.md
- [key decision: major library, architecture, API, or data-model choice]
- [key decision]
⚠ Verify: [embedded assumption or placeholder worth a sanity-check — advisory, omit if none]
❓ Decide: [open decision the user must confirm or change before the next command, phrased as a question with the provisional value — omit if none]

[Optional hook block if active]

Next:
- `mano [action]` — [when it is useful from the current artifact state]
```

`mano spec` must surface embedded assumptions on the right channel (see the canonical execution-log format in `_mano/workflow.md`): `⚠ Verify:` for assumptions the user can sanity-check at leisure; `❓ Decide:` whenever the confirmation should happen **before the next command** — a provisional default, a value the brief demanded a deliberate call on, a stated-preference override. If you catch yourself writing "confirm before stories" into a verify line, it's a decide. A pending `❓ Decide:` makes the `Next:` recommendation conditional on it — never announce "ready to decompose" above an unanswered decision. Overriding a directive in the brief's `## Stated Technical Preferences` block always trips a `❓ Decide:`, paired with the inline `⚠️ Note:` per the mandatory override-flag rule above. Never ship a stated-preference override silently. When the user answers a decide, apply the answer to `tech-spec.md` in place — the provisional value becomes a stated decision, the hedge comes off — and reply with a one-line changelog.

Populate the canonical `Next:` block from the actions that are still missing or worth refining:
- `mano rules` — if implementation conventions, file structure, error handling, validation, or framework patterns need codifying. When `project-rules.md` does not yet exist, state what it buys rather than just noting its absence: without it the first coding agent invents file layout and naming per-story, and later stories drift; `mano rules` pins these once so stories stay consistent. This is especially load-bearing for engines/frameworks with no enforced project layout.
- `mano stories` — if the phase is technically clear enough to break into implementable work
- `mano ux` — only if user-facing flows, frontend behaviour, interaction design, or product experience decisions are part of this phase
- `mano ui` — only if visual design, components, layout, or UI system decisions are part of this phase
- `mano continue` — only if it adds value and there may be a single obvious next step

## Forbidden

- Do not use conversational openings or closings ("Hey!", "How does this look?", "Let me know").
- Do not stop for routine apply confirmation. Stop only for a conflicting value or other decision the shared workflow explicitly reserves for the human.
- Do not include API endpoint designs for apps without APIs.
- Do not include deployment architecture for small projects.
- Do not include security architecture beyond what the brief specifies.
- Do not include performance benchmarks unless relevant.
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
- Do not put implementation patterns (project-wide signature/error conventions, file-IO helpers, folder structure) in the spec — those are `project-rules.md` territory. This explicitly includes the two recurring leaks the **Drain check** targets: concrete on-disk file paths (`prisma/dev.db`, `db/schema.ts`, migration dirs) and accessibility/coding *patterns* phrased as contributor obligations ("use native `<button>` not custom widgets"). The spec keeps the decision/constraint that motivates these; the path and the how-to drain out. Applies even when `project-rules.md` does not exist yet — an unhomed pattern is a `rule-gap`, not spec content. Exact consumer-visible contracts remain in the spec under the Public interface completeness check.
- Do not write implementation code, private/internal helper signatures, or exact UI/rendering math.
<!-- /mano-rule: public-interface-contract-readiness -->
- Do not list phase-level scope ("not in this phase," "deferred to Phase N") — phase scope belongs in the phase brief. Out of Scope in the spec is for architectural commitments only.
- Do not mention the current Phase number anywhere in the generated spec, except in a one-line replacement note when a significant decision was superseded.
