# Mano artifact rules

Shared rules for skills that write planning artifacts. A skill's front-matter names this file in `requires:`; read it once at activation, with `_mano/rules/core.md`.

## Artifact Quality

Planning artifacts are written for human readers — people who will read, discuss, edit, and act on them. They are not structured inputs for AI models.

### Plain-language contract

Every Mano skill applies this contract to artifact prose and user-facing messages.

This contract overrides stylistic wording in examples. It does not override behavior, labels, or exact contracts.

**Goal:** a teammate with no prior context should understand the text on the first read. Length is not the target. Understanding is. Prefer a complete plain sentence over clipped fragments.

#### Say what happens

- Use active voice. Name the person, system, or component that acts.
- Use familiar, literal words. Define unavoidable jargon when it first appears.
- Replace abstract nouns with actions. Write “the animal reacts,” not “animal-driven feedback.”
- Do not use marketing words as requirements. Examples include “seamless,” “intuitive,” “elegant,” “smart,” “robust,” and “user-friendly.”
- Do not use a metaphor as a requirement. Keep metaphors inside vision or quoted product language.

Product-feel words still belong in product work. “Fun,” “calm,” and “rewarding” can state a vision or learning question. Name who will judge that feeling and how they will experience it. Never treat the adjective alone as acceptance evidence.

#### Ask clear questions

- Ask only when the answer changes the current work. Never ask someone to repeat a recorded decision.
- Name the phase, artifact, or behavior that the answer affects. Avoid an unclear “this” or “it.”
- Put one decision in each numbered item. Group related decisions when the person can answer them together; do not force one question per message.
- Explain why the answer matters only when the consequence is not obvious.
- Offer options only when the real choices are known. State what each choice changes. Ask an open question when a shortlist would hide or bias valid answers.
- Accept a natural-language reply unless an exact command or value is required.

Do not turn every question into a requirements form. The reader needs a clear decision and consequence, not mandatory Trigger, Outcome, and Edge Case fields.

#### Put concrete detail in its canonical home

Describe each idea at the level the current artifact owns. Do not invent technical detail merely to sound precise.

- A phase brief states user-visible behavior and scope boundaries.
- A UX flow states user actions, system responses, branches, and recovery paths.
- A design brief states visual decisions, states, and owned design values.
- A technical specification states contracts, states, parameters, defaults, bounds, and failures.
- A project rule states when it applies and what it requires or prohibits.
- A story states its trigger, observable result, relevant failure cases, and implementation references.

When a technical system hides important parts, its owning artifact must name them. List concrete states, transitions, inputs, outputs, defaults, or endpoints there. Other artifacts reference that definition instead of copying it. If the required definition does not exist, ask or route to its owning Mano skill. Never fill the gap with confident-sounding prose.

#### Unpack dense logic

Use bullets when one requirement contains multiple:

- triggers
- conditions
- actions
- results
- exceptions

Keep one decision or behavior in each bullet. Preserve the order in which events occur. Do not force a simple sentence into fragments merely to reduce its word count.

For Exit Criteria and `Done when`, put the trigger on the parent line. Put each condition, result, and exception in a nested bullet. Never compress several observable results into one checkbox sentence. Every nested result remains required.

Bad:

> When the user submits, save the record, notify them, and disable the form unless validation fails.

Clear:

> When the user selects Submit:
> - Validate every required field.
> - If validation fails, show inline errors and stop.
> - Save the record.
> - Send the confirmation.
> - Disable Submit until a field changes.

#### Make parameters honest

Words such as “configurable,” “tunable,” “fast,” and “scalable” are incomplete requirements. Do not use them instead of a decision.

When the current artifact owns the value, state the relevant details:

- default value and unit
- allowed bounds or options
- where someone changes it
- behavior outside the allowed range

If the value remains undecided, ask for it or mark it provisional through the normal decision protocol. Never invent a default to remove an open question. When another artifact owns the value, reference that artifact instead of repeating the number.

#### Make requirements testable without adding ceremony

A requirement gives the reader enough information to answer:

- What starts this behavior?
- What should the user or caller observe?
- Which failure or edge case matters here?
- Which adjacent behavior remains outside scope when confusion is likely?

Do not add empty Trigger or Out of Scope fields to every item. Use the structure that fits the artifact. A backlog idea can state a problem and an honest unknown. Exit Criteria and story acceptance criteria require observable proof. Technical contracts require exact success and failure behavior.

#### Clarity check

Before finalising, read the text as a new teammate:

- Can they identify every actor and important noun?
- Can they explain what happens without guessing?
- Could two readers implement conflicting behavior from this wording?
- Does a vague adjective carry a requirement by itself?
- Does this artifact invent detail owned elsewhere?

Add missing context. Split dense logic. Route missing decisions. Remove repeated detail.

The `Implementation Reference` section serves coding agents. Keep its technical precision. Apply the same clarity rules wherever exact contracts allow.

If a section reads like structured machine-parseable metadata rather than human communication, it is too heavy. Trim it, merge it with adjacent content, or leave it out.

## Compactness Guidelines

Artifacts should prioritize clarity over completeness.

Prefer:
- short sections
- tables over prose
- concrete decisions over speculation
- current-phase needs over future-proofing

Avoid:
- speculative scalability planning
- unused abstractions
- excessive rationale
- documenting hypothetical futures

## Shared Values: One Canonical Home

A shared fact — a measurement, constant, threshold, contract value, token, or any number a future contributor must apply consistently — has exactly **one owning artifact** that states its value, its unit, and the rationale for it. The owner is the artifact closest to the decision: usually `tech-spec.md` for a technical constraint, `design-brief.md` for a purely visual token. When the value is enforced at runtime, it is mirrored by exactly one named code constant (e.g. `TOUCH_TARGET_MIN_PX`), and the code constant is the runtime source of truth.

Every other artifact **references the owner by name** ("touch targets meet the minimum defined in `tech-spec.md`") instead of restating the number. The number lives once, in the one place a reader would look for it.

Stating the same value in a second artifact is drift, not redundancy — and stating it in a *different unit* (e.g. `44pt` in one file, `88px` in another, `36px` in a third) is the most dangerous form, because it hides agreement and disagreement equally: a reader cannot tell whether `44pt` and `88px` are the same fact or a conflict. When you find a value expressed in mixed units across artifacts, converge them on the owner's single unit, or convert and cite ("44pt = 88px at 2× DPI") only in the owning artifact.

This applies to **every** artifact edit, whether made inside a skill or as a direct request. Propagating one value into several files and reporting that as completed alignment is the failure this rule exists to prevent — alignment means converging on the reference, never replicating the literal.

## Conflicting Values: Surface, Do Not Reconcile

Before writing a value that already appears in another artifact, check whether the existing copies agree — comparing the *fact*, not the *string* (`44pt` and `88px at 2×` agree; `44pt` and `36px` do not).

If they differ in number or in unit, **stop and surface the conflict for a human decision** before writing anything. State what each artifact currently holds and which one the human's instruction would change. Never silently converge the values, never silently pick the number from the latest instruction, and never report a reconciliation as completed work. A pre-existing cross-artifact disagreement is a decision the human owns — it may encode an intentional difference, a forgotten backport, or a real bug — and the agent's job is to make it visible, not to flatten it. Reporting "updated all N files to the same value" over a conflict the human never resolved is the exact failure this rule prevents.

## Skill Tightening

Use these patterns inside skills when outputs start becoming vague, overconfident, or too broad.

### Anti-Rationalization

Do not allow a skill to excuse weak work.

If the available context is insufficient, the skill should:
1. state what is missing
2. explain the risk or tradeoff
3. produce a smaller useful output if possible
4. avoid inventing certainty

### Exit Criteria

Before finalizing an artifact, check that it is:
- scoped to the current phase
- human-readable and directly editable
- free of unnecessary process or speculative future work
- explicit about assumptions and unresolved questions
- useful for the next action

### Progressive Disclosure

Default to the smallest relevant context.

Only request or load additional artifacts when they materially change the current output.

## Next-step suggestion rule

Whenever a skill suggests what to do next, base that suggestion on the artifacts that are actually missing or stale in `_mano_output/` — read the state projection's `ARTIFACTS:` line rather than opening files to check existence — not on a canonical pipeline order.

Rules for the `Next:` block, shared by every skill:

- Include only the Mano actions that are actually useful from the current artifact state.
- Omit actions whose artifacts already exist and do not obviously need refinement.
- If only one next action is genuinely obvious, list just that one action plus `mano continue` only if it still adds value.
- If several next actions are valid, list them all instead of prescribing a fake sequence — do not fake certainty.
- Keep the one-line reason style: `` `mano <x>` — <when it applies> ``.
- Prefer the shortest path that adds useful clarity for the current phase.

### Planning coverage for user-facing phases

Planning artifacts remain optional to the human; auto mode must not silently skip ones whose decisions materially shape implementation. Apply these checks when `mano start` proposes an auto chain and whenever Stories checks readiness:

- Include `mano ux` when the phase creates or materially changes an interactive surface whose user path is not already covered: multiple selectors/actions, advanced or conditional controls, responsive interaction changes, navigation, staged disclosure, or several meaningful UI states. This includes **player-facing game loops**: direct world interaction, placement/selection, unlock or progression actions, available-versus-locked states, or feedback that explains why an action cannot yet succeed. When two or more tools, buildables, abilities, modes, or rewards can be available together, UX must define the player's choice and active-choice feedback; a hardcoded default cannot stand in. “In-world”, “minimal”, or “not a menu” does not make an interaction flow self-evident. One screen is not automatically one obvious flow.
- Include `mano ui` when the phase creates or materially changes a rendered screen, component composition, responsive layout, visual hierarchy, or distinguishable visual states and the cumulative design brief plus exact current-phase preview do not already cover them.
- A familiar or “canonical” widget defines neither the product's composition nor its responsive layout, hierarchy, state treatment, or accessibility cues. It is not evidence that UX/UI guidance is unnecessary.
- In manual mode, show the useful actions and let the human skip them. In auto mode, include them in the proposed run plan by default; only an explicit approval edit such as `go, skip ux` or `1, skip ui` removes them.

“Optional” means the human may decline the planning surface. It does not authorize the agent to make that decline while constructing a hands-off run.

### Planning-stage decision tree

- Do not suggest a command just because it usually comes next if its artifact already exists and is still usable.
- If several planning actions are valid, present them as options rather than a single prescribed next step.
- **Which implementation action a planning skill names is not a style choice.** A planning skill always runs at the no-ledger stage, which is the one case where the mode decides: in `manual`, offer **both** `mano stories` (decompose into story files first) and `mano build` (build straight from the brief, no story files) and let the human pick; in `auto`, the approved chain terminates at `mano build`, so name that one. Read `MODE:` from the state projection — never infer the path from which one appears more often in examples. Once a ledger exists, the path is no longer open: a stories index means `mano dev`, a `progress.md` means `mano build`, and neither is a planning skill's call.
- Use this decision tree when evaluating next steps for the planning stage. Where it says **implementation**, substitute the rule above:
  ```
  Phase introduces a new category of file/example/module/component
  whose naming, placement, or shared format will repeat?
  └─ yes → keep `mano rules` in the options, however mature project-rules.md is

  Phase is user-facing or mobile?
  ├─ design coverage or the current visual preview missing/stale? → suggest `mano ui` (do not auto-run implementation)
  ├─ project-rules still default? → list `mano rules` + implementation as options
  └─ design coverage, visual preview, and useful rules present? → suggest implementation

  Phase is non-user-facing (backend/infra)?
  └─ go straight to implementation unless tech is genuinely fuzzy (suggest `mano spec`)
  ```
  The first branch exists because the others are asymmetric: `mano ui` is gated on a **phase-scoped** artifact (`PHASE_DIR/design-preview.html`), which is missing at the start of every phase, while `mano rules` was gated only on `project-rules still default?` — a **project-lifetime** condition that can never fire again once the file is customised. Existence of `project-rules.md` proves earlier categories were homed; it says nothing about a category this phase introduces. Judge rules by what the phase adds, not by whether the file has been written before.
