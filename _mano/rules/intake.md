# Intake Boundaries (B1–B5)

Shared by the intake skills — `mano start` and `mano import` — that turn an idea or a document into backlog items. This is the **single source of truth** for what an intake skill may and may not ask, and when. Those skills reference these by name instead of restating them. If a skill step and this file ever disagree, this file wins.

## B1 — Tech-boundary (every question, every path, every step)

Intake asks *what the product does and for whom*, never *how it's built*. Before asking any question, check it is not a tech question in disguise.

- **Forbidden:** tech stack, frameworks, libraries, styling, state management, persistence mechanism (localStorage vs. file vs. SQLite vs. server DB), API shape, hosting, schema. These are for `mano spec` to decide. Never present the user a menu of storage or implementation options.
- **Allowed (the scope half):** "Does Phase 1 run fully locally with no login?" is a scope boundary — keep it. "How does data persist — localStorage, a file, or SQLite?" is implementation — drop it. When a question has both a scope half and a mechanism half, ask only the scope half.
- A missing technical detail in a brief or document (auth mechanism, error format, persistence, API shape) is **not a gap intake fills**. "Stores data" without saying how is correct for this stage.
- **Pass-through, not silence:** B1 forbids intake *eliciting, evaluating, or deciding* tech. It does **not** license *discarding a technical preference the source already states*. When the input explicitly states a stack/framework/storage/auth directive ("Use Next.js", "Use a SQL database", "auth can be deferred if Phase 1 is a local prototype"), intake does not act on it, decide it, or weigh it — but **must transcribe it verbatim** into the phase brief's `## Stated Technical Preferences` block (see `mano start`'s phase brief output) so it survives a context reset and reaches `mano spec`. When the intake skill produces only a backlog (`mano import`), preserve the stated directive verbatim in the relevant backlog item's context so `mano start` can carry it into the brief later. Dropping a stated directive because "tech isn't intake's job" is the failure: ignoring-for-scoping is correct; discarding-from-the-record is not. Intake still asks no tech question and makes no tech choice — this is a courier duty, not a decision.

- **Every stated directive gets a home — "no item owns it" is not a reason to drop it.** The pass-through clause above assumes each directive belongs to some feature item. The project-wide ones do not: a runtime or version constraint, a module system, a folder structure, a file-naming scheme, a test-layout rule — each spans every item and therefore attaches to none, which is exactly how they get lost between the source document and the first line of code. When a stated directive has no single owning item, intake gives it **its own backlog item**, typed by the artifact that will own the decision:
  - `spec-gap` → `tech-spec.md`, resolved by `mano spec`: runtime and version constraints, language or dialect, module system, storage mechanism, libraries, package manager, interface shape.
  - `rule-gap` → `project-rules.md`, resolved by `mano rules`: folder structure, file layout and naming, code conventions, component patterns, where tests live.

  The title names the directive (`Stated: project directory structure`); the context carries it verbatim. The gap type here is a **routing address, not a verdict** — intake still evaluates and decides nothing, and these items are the only channel that puts an unattached directive in front of `mano spec` / `mano rules` instead of nowhere. `state.js --scope` excludes gap items from phase-scope selection, so homing one never inflates a phase.

  **Verbatim, within the 5-line context budget.** Quote the source sentence unchanged when it fits. When the directive is a block the budget cannot hold — a directory tree, a table, a fenced list — name its exact source heading and transcribe on one line the literal values it states (the paths, names, versions), unchanged. Never paraphrase a value, and never summarise the block away.

  - ❌ Don't: read a stated minimum runtime version and a `Project Directory Structure` tree, conclude neither belongs to any feature item, and write the backlog without them — the implementer then invents its own layout and the human finds out after the code exists.
  - ✅ Do: emit a `spec-gap` item carrying the runtime line verbatim, and a `rule-gap` item carrying the exact source paths that tree states.

## B2 — Closed-scope (every question, every path)

Do not re-open scope the input already closed. If the brief says "manual entry only," do not ask whether import could be added "as a shortcut" — that expands scope. If an adjacent capability is worth recording, note it as a candidate backlog item, never as a clarifying question.

## B3 — Scope-sizing-deferral (intake only)

Intake clarifies *what the product is*, not *what goes in Phase 1*. Phase sizing and slicing happen at `mano start` Step 6, against the one-independently-verifiable-outcome constraint, after the backlog exists.

- Do not ask the user whether Phase 1 should be narrowed, what the minimum viable set is, or whether they're "open to" a smaller slice. That is Step 6's decision to *propose*, not intake's to *ask*.
- Do not float a candidate decomposition ("e.g. dashboard view-only, no CRUD") during intake. Suggesting a slice shape is proposing a solution — forbidden by the planner role.
- Do not resolve a deferral-vs-reference contradiction by asking the user to size Phase 1. When the document defers a capability ("recurring later") but also references it elsewhere ("dashboard shows upcoming recurring expenses"), that is a foundation conflict for `mano start` Step 7b, not an intake question. B2 already closed the deferral and B3 forbids the sizing — so **both the sizing form and the confirmation form are forbidden**. The confirmation form is the subtler trap: rewording a banned sizing question as a yes/no does not make it askable, because the answer is still "what's in Phase 1," not "what the product is."

  Worked example — capability is deferred ("early phases can start with one-off expenses") but the dashboard references "upcoming recurring expenses":
  - ❌ Don't (sizing form): *"For this phase, only one-off expenses, or model recurring too?"*
  - ❌ Don't (confirmation form): *"Does that mean recurring expenses are fully out of Phase 1?"* — still phase-sizing; the document already answered it.
  - ✅ Do: ask nothing. Log an Assumption Log candidate for `mano start` Step 7b: *"Phase 1 deliberately models one-off expenses only; the deferred recurring item must extend this model, not rework it."*

  Log it for the Foundation-conflict check; never ask it, in any form.
- An input that looks too large for one phase is *expected* and is exactly what Step 6 resolves. Note it to yourself, decompose it fully into the backlog, and let a tight Step 6 shortlist solve the sizing — never by interrogating the user up front.

## B4 — No solutioning (every step)

Intake is planning. Do not propose architecture, decomposition shapes, libraries, or implementation approaches at any step — not in questions, not in findings, not in the brief or backlog.

## B5 — Source-read boundary (every path, every step)

Intake scopes from planning artifacts (backlog, previous brief, reviews) and the user's answers — not from the codebase. Do not read source code to enumerate the work or to verify defects.

- **Forbidden:** reading source files, type/export indexes, or implementation to build the work inventory ("which exports lack docs", "which screens are missing a test"), to confirm a defect exists, or to diff current code against a desired state. That gap analysis is `mano stories`' job (decomposition) or the implementation's; producing it during intake pre-decides scope the human is supposed to set, and loads the expensive context planning is meant to avoid.
- **Allowed (narrow):** a quick *structural* glance — directory layout, where a kind of file lives, whether a folder exists — solely to ground a scoping *question* you then ask the user. "Docs live in `packages/*/docs`, one page per export — should the phase be 'every public export has a doc page'?" is grounded-question territory. Enumerating the actual missing pages from the export list is not.
- The test: are you reading to **ask a better question**, or to **answer it yourself from code**? The first is allowed and minimal; the second is the overreach. When in doubt, ask the user rather than open a source file.
- This holds even for "document/refactor the code" phases where the code is the subject. The code being the subject makes it tempting to mine, not licensed to. Scope the intent with the user; let `mano stories` enumerate against source.

These boundaries are also enforced negatively in each intake skill's **Forbidden** list, which points back here rather than restating the detail.
