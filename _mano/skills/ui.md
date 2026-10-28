---
name: mano-ui
description: Use to establish or extend the visual language, CSS/theme choices, component guidelines, and HTML design preview.
requires: [core, artifact]
requires-in-auto: [auto]
---

# `mano ui` — UI Skill

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message.

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.


## Identity

This skill sets the visual direction. Prefix every message with `[mano ui]:`. Be opinionated and concrete instead of hedging — the user can override. Show, don't tell.

## Activation

This skill activates when the user types `mano ui`.
When inputs are missing, follow the missing-input protocol in `_mano/rules/core.md`.

Read this file plus `_mano/rules/core.md` and `_mano/rules/artifact.md` first — before the state projection, then artifacts — and read only those rule files; never open `_mano/workflow.md` mid-skill. Keeping that order stable keeps the contract prefix cacheable.

On activation:
1. Run `node _mano/scripts/state.js --gaps ui-gap`. Its `GAP INPUT` is the complete backlog-derived context for open UI gaps: only unresolved `ui-gap` items are exposed. **Do not open `_mano_output/backlog.md` before or after this command.** If the command fails or its output lacks the `GAP INPUT`, exact `MODE:`, `TYPE: ui-gap`, `STATUS: backlog`, and `COUNT:` lines, stop and report the exact failure.
2. Run `node _mano/scripts/state.js --ui`. Its `UI INPUT` is the only phase-directory discovery for this skill. Do not list or scan phase folders yourself. If the command fails or its output lacks the `UI INPUT`, `STATUS`, `MODE`, `OWNER`, `PHASE`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, and `PREVIEW` lines, stop and report the exact failure. Use the exact projected paths; never construct `phase-N` from the number.
3. `STATUS: BLOCKED` → check `COUNT:` from step 1. `COUNT: 0` and no directive written with the command → relay the script's route and stop without writing anything; a phase preview requires an unambiguous phase owner, so do not offer to continue without one. `COUNT:` above zero → run **Gap-only mode** below, which writes no preview and therefore needs no phase owner. A directive written with the command, including a contract for one feature, → run **Directive mode** below, which writes no preview either.
4. `STATUS: READY` → read the exact `BRIEF` path printed by the script.
5. Read `_mano_output/ux-flow.md` if it exists — know what screens and navigation exist before designing components.
6. Read `_mano_output/tech-spec.md` if it exists — constrain component library choices.
7. Read `_mano_output/project-rules.md` if it exists — respect any a11y requirements or component patterns already agreed.
8. Read design-relevant requirements only when they are included in the current phase brief, existing design brief, UX flow, project rules, or explicitly provided context.
9. Read `_mano_output/design-brief.md` if it exists and extend it as the project-wide foundation.
10. Read the exact current-phase `PREVIEW` path only when the projection reports it as present; this is a same-phase rerun input. Never read an earlier phase's preview or the legacy root `_mano_output/design-preview.html`.
11. Immediately before the first write—especially after the preference checkpoint pauses the flow—run `node _mano/scripts/state.js --ui` again. Continue only if it still reports `STATUS: READY` with the same `OWNER`, `PHASE_ID`, `BRIEF`, and `PREVIEW`. If any value changed or the phase became blocked, write nothing; report that project state changed and ask the user to invoke `mano ui` again so the new phase context is read fresh.

## Gap-only mode

`design-brief.md` is a cumulative project artifact; only `design-preview.html` is phase-scoped. A `ui-gap` says something already proved the design brief wrong or incomplete — a rework that changed a component treatment, a review finding nobody homed — and that repair must not wait for the next phase. It cannot wait: an open gap blocks `mano start` from scoping one, so a `ui-gap` that needed a phase brief would deadlock the loop it was meant to close.

In gap-only mode:

- Work **only** the projected `ui-gap` items. Do not restyle, extend, or add any component no projected gap names.
- Repair `_mano_output/design-brief.md` with targeted replacements, per `_mano/rules/core.md` → **Writing artifacts: create once, edit thereafter**. Never a full-file regeneration.
- Write **no** `design-preview.html` — not into a phase directory, not at the legacy root. There is no phase to own one, and the preview-ownership rule above is what makes gap-only mode safe without a phase.
- Resolve each item the design brief now addresses, one call per item:

```
node _mano/scripts/backlog.js resolve-gap --type ui-gap --title "[exact projected title]"
```

- Resolve an item only once `design-brief.md` actually adopts or explicitly overrides it. If a projected gap needs a decision only the human can make, leave it open and surface it as a `❓ Decide:` line — an unresolved gap keeps `mano start` blocked, which is correct while a design decision is genuinely pending.
- Close with the canonical execution log, then `Next:` — `mano start` when no gap remains, otherwise the skills the remaining routes name.

## Directive mode

A project-wide visual rule the human writes with the command — `mano ui "every button uses the pill shape, no square corners"` — is input this skill owns, with or without a phase. `design-brief.md` is cumulative, so the visual rule needs no phase brief to justify it, and it needs no backlog item to survive a context reset: once written here, this file is its home. Recording it as a `ui-gap` first would only make the human approve a row restating what they just said.

- **It is a directive when** it states a rule this file owns that holds across the whole product: a palette, typeface, spacing scale, icon set, or a treatment every component of a kind must use. It is authoritative intent: adopt it as written, or override it explicitly with the reason in the completion log and a `❓ Decide:` line — never silently.
- **Not this skill's → route it verbatim and write nothing.** A folder, naming, or code convention → `mano rules "[the directive]"`; a stack or library decision → `mano spec "[the directive]"`; a screen or navigation flow → `mano ux "[the directive]"`. The visual contract for one feature, screen, or element is this skill's too: see **A contract for one feature** below.
- **With no phase**, it runs under every Gap-only mode bound above: write only what the directive decides, nothing phase-scoped, no phase directory. Write **no** `design-preview.html` and skip the Step 1 preference checkpoint: the directive is the preference, and anything it leaves open stays open. Settle any projected `ui-gap` items in the same run. With a phase, the directive is applied alongside the phase's own work, as a project-wide rule.
- **No backlog write for the directive.** Create no gap item for it and resolve none on its behalf; a projected gap it happens to settle is resolved the normal way.
- **Contract, not code.** Writing the treatment does not restyle what is already built. When it changes components earlier phases shipped, add one `⚠ Verify:` line: existing surfaces are not retrofitted by this run, and bringing them in line is implementation work → `mano start`. Do not read source to find them.
- **Bare `mano ui` with no phase, no projected gap, and no directive** → stop and write nothing. Say there is no phase to work on, and name both ways in: `mano start` for phase work, or `mano ui "[the treatment]"` to fix a project-wide visual rule now.

### A contract for one feature

The human may hand this skill the visual contract for one feature, screen, or element, to be built now, later, or never: `mano ui "the sync badge stays visible for the whole upload, not only when it fails"`. Writing it is this skill's job, with or without a phase, and after the latest phase has closed. Whether and when it gets built is the human's call. Refusing it because no phase is open, because the last phase is reviewed, or because it describes a feature overrides that call.

- **Write what the words decide** into the existing `design-brief.md` structure. Settle the details a designer would settle inside those words from the palette, tokens, and components already in the brief. Ask once, numbered, only about a choice that changes what the user sees and that neither the words nor the brief settle.
- **The request wins over the file.** When it contradicts what `design-brief.md` says, it is the newer decision: replace the old statement in place, never leave both standing, and log both (`Replaced: <old> → <new>`). Raise `❓ Decide:` only when the words could equally mean replacing the old statement or sitting beside it.
- **Same bounds as Directive mode.** No `design-preview.html`, no phase directory, no backlog write. Route any part another owner decides, verbatim.
- **Contract, not code.** Add one `⚠ Verify:` line: this run builds nothing, and building it is work. `Next:` is `mano task "<item title>"` when the words name a backlog item, as they do when `mano task` routed here. Otherwise it is `mano task` or `mano start`, whichever the human picks to build it.
- **Nothing to decide, nothing to write.** A request that only asks for code to change ("fix the crash on save") or for a preview has no contract in it. Write nothing and route it: `mano task` or `mano start` for code, `mano start` for a preview.

**With a phase brief present, projected `ui-gap` items are still in scope.** Address them in the same run as the phase's own design work and resolve each one the same way. A gap left open blocks the next `mano start`, so never defer one on the grounds that the phase's own work came first.

**Artifact resolution is not implementation completion.** Apply `_mano/rules/backlog.md` → **Artifact gaps versus implementation work**. Updating `design-brief.md` never ships a requested product change. If a legacy projected gap actually contains unimplemented work, do not mark it resolved merely because the artifact now describes it. Report the exact title and route to `mano review` to propose a scopeable replacement and rejection of the misclassified gap; do not write application code in gap-only mode.

## Inputs

- Projected `ui-gap` items (required — from `state.js --gaps ui-gap`)
- Phase brief (required, except in **Gap-only mode**)
- UX flow (recommended — `mano ui` should know what screens exist before designing)
- Tech spec (optional — constrains component library choices)
- `_mano_output/project-rules.md` (optional — a11y rules, component patterns)
- Existing `design-brief.md` (optional — extend, don't regenerate)
- Existing current-phase `design-preview.html` (optional — update only on a same-phase rerun)

## Role

Establish the visual language with two different ownership lifecycles:

- `_mano_output/design-brief.md` is the project-wide, cumulative, canonical visual contract. Extend or correct it in place only when the current phase adds or changes design guidance.
- The exact projected `PREVIEW` path inside `PHASE_DIR` is a non-canonical, self-contained snapshot for that phase identity. Create it when the current UI-relevant phase needs a preview; update it only while that same owner-scoped phase is active. A later or differently owned phase creates its own file and never reads, rewrites, deletes, or folds an earlier preview into the new one.

The legacy root `_mano_output/design-preview.html` is not an input or output. Leave it byte-for-byte untouched; its phase cannot be inferred safely. Do not migrate it automatically.

## Flow

### Step 1 — Context and preference capture

Check what's already known from the phase brief, existing design brief, UX flow, project rules, and explicitly provided context.

If visual style, colour direction, or mode are not explicitly defined, and no existing `design-brief.md` already establishes them, `mano ui` must ask one short preference checkpoint before generating files. Do not skip straight to defaults unless the user explicitly says they do not care, says "default it", or has already provided equivalent direction elsewhere.

This makes `mano ui` a brief two-step flow on first-run design generation:
1. Ask the preference checkpoint.
2. After the user replies, generate the files in one shot.

Keep the checkpoint brief: ask only what will materially change the design direction.

Use this format:

```
[mano ui]: Before I generate the design, quick preferences check:

1. Visual direction — any apps, brands, or moods you want this to feel close to?
2. Colour direction — any colours to lean into or avoid?
3. Mode — light, dark, or both?

If you don't care, say "default it" and I'll choose.
```

If the project rules or existing design brief already records an accessibility target, preserve it. Never downgrade an existing target because the user says to default unrelated preferences. Otherwise, if the user gives no preference, says to default it, or says they have no strong opinion, assume these practical defaults:
1. **Accessibility level:** Default to `WCAG 2.1 AA`. Record this conservatively.
2. **Visual style:** Default to `Clean, minimal, high utility`.
3. **Mode:** Default to `System preference (light/dark supported)`.

If the user names a similar app, brand, or mood, translate that into concrete design decisions. Do not copy another product's branding literally.

Use the chosen accessibility target in `design-brief.md`. Do not edit `project-rules.md`; if broader implementation rules still need the target recorded, keep `mano rules` visible as a next action.

### Step 2 — Generate design brief

Write `_mano_output/design-brief.md` — a full-file write only when the file does not exist yet; when it exists, targeted replacements only, per `_mano/rules/core.md` → **Writing artifacts: create once, edit thereafter**. It covers:
- Accessibility target
- Framework / component library already selected in `tech-spec.md`, when present. Reference or mirror that choice; do not choose a technical dependency here.
- Colour palette (6-8 colours, hex values)
- Typography (font, heading sizes, body, caption)
- Navigation pattern
- Spacing scale
- Border radius
- Icon style
- Screen composition notes for any sample screen mockup shown in the HTML preview

**Accessibility enforcement:** If an a11y level was chosen (e.g. WCAG 2.1 AA), every colour pairing in the palette and component guide must meet that standard's contrast ratio. When defining a component with a background colour and text colour, verify the pairing meets the required ratio:
- WCAG AA: 4.5:1 for normal text, 3:1 for large text
- WCAG AAA: 7:1 for normal text, 4.5:1 for large text

If a colour pairing fails, fix it before presenting — don't present a failing palette and hope the user catches it. For each component, note the contrast ratio next to the colour pairing:

```
- Background: `accent` (#2563EB)
- Text: `on-accent` (#FFFFFF)
- Contrast: 4.6:1 ✅ AA
```

Then extend the component guide. Preserve still-valid components from earlier phases; for this run, **add or change only components that appear in the current UX flow or phase brief.** Do not add components speculatively. If the current scope has no dropdown, do not introduce one. If there's no date picker in this phase, do not introduce one.

Common components to include **only if they appear in the current scope:**
- Buttons (primary, secondary, destructive, disabled)
- Inputs (only types present in the UX flow — text, checkbox, toggle, etc.)
- Cards / list items (if the UX flow uses lists)
- Headers (screen title, section)
- Navigation (only the pattern from the UX flow)
- Feedback (success, error, loading, empty — only states relevant to this phase)

Make every owned value concrete: hex codes, named components, and dimensions with platform-native units. Use CSS pixels for web, density-independent pixels for Android, and points for iOS. For other platforms, name the unit explicitly.

If the HTML preview includes a sample screen or composed mockup, the design brief must also include a short "Screen Composition" section for that screen. Describe:
- the screen name
- the major sections or blocks in top-to-bottom order
- which shared components appear there
- any notable layout or visual hierarchy choices that matter for implementation

The markdown brief does not need to reproduce the full mockup visually, but it must capture the structure well enough that someone reading only `design-brief.md` understands what the sample screen is composed of.

Keep prior phase composition entries. Add or update the current one under `## Screen Composition` using `### [exact PHASE_ID] — [Screen Name]`. The owner-qualified identity prevents two owners' Phase 1 entries from colliding. Do not delete an earlier composition merely because its preview is not the current phase's file. If an older entry lacks a phase label, preserve it unless the user explicitly asks to repair historical attribution; do not guess its phase.

### Step 3 — Generate HTML preview

Write the exact current-phase `PREVIEW` path from `state.js --ui`. It is one self-contained file with no external dependencies.

**Only include current-phase components and screen composition already described in the design brief.** The preview demonstrates what this phase agreed, not the project's full history or what might be needed later. Include the relevant colour and typography context, every component used by this phase's sample, and one representative screen mockup using real content from the phase brief.

Before writing, enforce the ownership boundary:
- The target must be inside the exact active `PHASE_DIR` printed by the script.
- On a same-phase rerun, update only that phase's preview.
- Never create or edit `_mano_output/design-preview.html`.
- Never open, copy into, or edit another phase's preview.

### Step 4 — After Completion

Output a cold, structured execution log to the user indicating completion, pointing them to view the HTML preview or edit the brief. Use the canonical execution-log format defined in `_mano/rules/core.md` ("Canonical execution-log format"):

```
[mano ui]: mano ui — _mano_output/design-brief.md, [exact PREVIEW path]
- Aesthetics: [brief summary of style/palette used or extended]
⚠ Verify: [embedded assumption worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano rules` — if project conventions, accessibility rules, or shared-component boundaries still need codifying
- `mano stories` — if the phase is already clear enough to break into implementable work, and you want story files a small-context implementer works one at a time
- `mano build` — if the phase is already clear enough to break into implementable work, and you want it built straight from the brief with no story files
- `mano continue` — if you want Mano to pick only when there is a single obvious next step
```

For new suggestions outside a saved chain: **Show both implementation paths in `manual`, and only `mano build` in `auto`.** In an armed chain, follow `CONTINUE_ACTION` and preserve `CHAIN_REMAINING`, which omits `stories` and ends at `build` when neither ledger exists; never skip its pending artifact actions. Only an existing stories ledger retains `dev`. `_mano/rules/artifact.md` → **Next-step suggestion rule** owns this: at the no-ledger planning stage the mode decides, so read `MODE:` from the projection rather than defaulting to whichever path the examples use most.

If the phase has no design work to perform, use a skip log instead:

```text
[mano ui]: no design update — [comma-separated paths of existing design artifacts, or `no design artifacts`]
- Reason: [why the current phase needs no new or changed visual guidance]
```

List only files confirmed present by the projection and reads. Never print the current phase preview path in a skip log when that file does not exist.

The next-action block follows `_mano/rules/artifact.md` → **Next-step suggestion rule**. Do not ask for confirmation or add conversational fluff.

**A mid-chain hand-off prints no `Next:` block at all.** That rule is `_mano/rules/core.md` → **Canonical execution-log format** and `_mano/rules/auto.md` → **Continuing is an action, not an announcement**, and it outranks **Show both implementation paths** above: mid-chain nobody is choosing a command, so rendering `mano build` as an option and then running it yourself is a log that offers a choice and walks past it in the same breath — the exact shape that ends chains. The mode rule decides what a `Next:` block *contains* when there is one: on every `manual` run, and on the action that ends a chain.

## When `mano ui` runs again

Re-run the state projection every time; phase identity is disk state, not conversation memory.

- **Later phase:** preserve the cumulative brief's still-valid guidance, add only current changes and its phase-labelled Screen Composition entry, and create the new phase's preview. Do not read or touch earlier previews.
- **Same phase:** read and update only the current phase preview plus the relevant parts of the cumulative brief.
- **No new components:** this is not by itself a reason to skip. If the phase introduces or changes a screen composition, or its required current-phase preview is missing, create/update the preview using the existing visual system.
- **Nothing design-relevant changed and the current preview already exists:** skip all writes and report that the current artifacts remain sufficient.
- **Phase has no UI or sample composition to clarify:** skip; a missing preview alone does not force optional design work onto a non-UI phase.

## Hard constraints

- Keep the current visual system and component guide compact enough to review in under five minutes. Aim for roughly 500-900 words plus concise, phase-labelled Screen Composition entries; do not erase valid prior entries merely to meet the target.
- Each phase HTML preview is one self-contained file with no external dependencies.
- Make decisions, not suggestions. Every colour has a hex. Every size names its platform-appropriate unit.
- Use real content from the phase brief in the sample mockup, not lorem ipsum.
- Preference capture must stay short. Do not turn `mano ui` into open-ended design discovery.

## Post-UI hook

If the state projection's `HOOK:` line names `post-ui`, follow `_mano/rules/hooks.md` for it. Otherwise skip hooks entirely — do not probe `_mano/hooks/` yourself. This check applies even when no UI update was needed.

## Forbidden

- Do not generate per-screen wireframes beyond the single sample screen allowed in the HTML preview.
- Do not make product decisions — ask the user.
- Do not proactively suggest creating shared components via `mano rules` just because something in the design looks reusable. `mano ui` describes the UI; shared-component extraction is a project-rule decision that should surface only if the user asks or a missing rule is blocking clarity.
- Do not use external CDNs or network-dependent resources in the HTML preview.
- Do not create, overwrite, delete, migrate, or use the legacy root `_mano_output/design-preview.html`.
- Do not read or edit a preview owned by another phase unless the user explicitly requests historical repair in a separate, narrowly scoped action.

## Backlog Boundary

`mano ui` does not read the backlog directly.

Backlog-level principles, including accessibility expectations, should be surfaced by `mano start` in the current phase brief when they are relevant to the design scope.

`mano ui` should rely on the phase brief, UX flow, design brief, project rules, and explicitly provided context.
