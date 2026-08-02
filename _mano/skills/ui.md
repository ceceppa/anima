---
name: mano-ui
description: Use to establish or extend the visual language, CSS/theme choices, component guidelines, and HTML design preview.
---

# `mano ui` — UI Skill

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.


## Identity

This skill sets the visual direction. Prefix every message with `[mano ui]:`. Be opinionated and concrete instead of hedging — the user can override. Show, don't tell.

## Activation

This skill activates when the user types `mano ui`.
When inputs are missing, follow the missing-input protocol in `_mano/workflow.md`.

On activation:
<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
1. Run `node _mano/scripts/state.js --ui`. Its `UI INPUT` is the only phase-directory discovery for this skill. Do not list or scan phase folders yourself. If the command fails or its output lacks the `UI INPUT`, `STATUS`, `PHASE`, `BRIEF`, and `PREVIEW` lines, stop and report the exact failure.
2. `STATUS: BLOCKED` → relay the script's route and stop without writing anything. A phase brief is required because the preview must have an unambiguous phase owner; do not offer to continue without one.
3. `STATUS: READY` → read the exact `BRIEF` path printed by the script.
4. Read `_mano_output/ux-flow.md` if it exists — know what screens and navigation exist before designing components.
5. Read `_mano_output/tech-spec.md` if it exists — constrain component library choices.
6. Read `_mano_output/project-rules.md` if it exists — respect any a11y requirements or component patterns already agreed.
7. Read design-relevant requirements only when they are included in the current phase brief, existing design brief, UX flow, project rules, or explicitly provided context.
8. Read `_mano_output/design-brief.md` if it exists and extend it as the project-wide foundation.
9. Read the exact current-phase `PREVIEW` path only when the projection reports it as present; this is a same-phase rerun input. Never read an earlier phase's preview or the legacy root `_mano_output/design-preview.html`.
10. Immediately before the first write—especially after the preference checkpoint pauses the flow—run `node _mano/scripts/state.js --ui` again. Continue only if it still reports `STATUS: READY` with the same `PHASE`, `BRIEF`, and `PREVIEW`. If any value changed or the phase became blocked, write nothing; report that project state changed and ask the user to invoke `mano ui` again so the new phase context is read fresh.
<!-- /mano-rule: ui-phase-preview-ownership -->

## Inputs

- Phase brief (required — warn if missing)
- UX flow (recommended — `mano ui` should know what screens exist before designing)
- Tech spec (optional — constrains component library choices)
- `_mano_output/project-rules.md` (optional — a11y rules, component patterns)
- Existing `design-brief.md` (optional — extend, don't regenerate)
<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
- Existing current-phase `design-preview.html` (optional — update only on a same-phase rerun)
<!-- /mano-rule: ui-phase-preview-ownership -->

## Role

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
Establish the visual language with two different ownership lifecycles:

- `_mano_output/design-brief.md` is the project-wide, cumulative, canonical visual contract. Extend or correct it in place only when the current phase adds or changes design guidance.
- `_mano_output/phase-[N]/design-preview.html` is a non-canonical, self-contained snapshot for Phase N. Create it when the current UI-relevant phase needs a preview; update it only while that same phase is active. A later phase creates its own file and never reads, rewrites, deletes, or folds an earlier preview into the new one.

The legacy root `_mano_output/design-preview.html` is not an input or output. Leave it byte-for-byte untouched; its phase cannot be inferred safely. Do not migrate it automatically.
<!-- /mano-rule: ui-phase-preview-ownership -->

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

If the user gives no preference, says to default it, or says they have no strong opinion, assume these practical defaults:
1. **Accessibility level:** Default to `WCAG 2.1 AA`. Record this conservatively.
2. **Visual style:** Default to `Clean, minimal, high utility`.
3. **Mode:** Default to `System preference (light/dark supported)`.

If the user names a similar app, brand, or mood, translate that into concrete design decisions. Do not copy another product's branding literally.

Use the chosen accessibility target in `design-brief.md`. Do not edit `project-rules.md`; if broader implementation rules still need the target recorded, keep `mano rules` visible as a next action.

### Step 2 — Generate design brief

Write `_mano_output/design-brief.md`:
- Accessibility target
- Framework / component library
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

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
Then extend the component guide. Preserve still-valid components from earlier phases; for this run, **add or change only components that appear in the current UX flow or phase brief.** Do not add components speculatively. If the current scope has no dropdown, do not introduce one. If there's no date picker in this phase, do not introduce one.
<!-- /mano-rule: ui-phase-preview-ownership -->

Common components to include **only if they appear in the current scope:**
- Buttons (primary, secondary, destructive, disabled)
- Inputs (only types present in the UX flow — text, checkbox, toggle, etc.)
- Cards / list items (if the UX flow uses lists)
- Headers (screen title, section)
- Navigation (only the pattern from the UX flow)
- Feedback (success, error, loading, empty — only states relevant to this phase)

Every value concrete: hex codes, pixel values, component names.

If the HTML preview includes a sample screen or composed mockup, the design brief must also include a short "Screen Composition" section for that screen. Describe:
- the screen name
- the major sections or blocks in top-to-bottom order
- which shared components appear there
- any notable layout or visual hierarchy choices that matter for implementation

The markdown brief does not need to reproduce the full mockup visually, but it must capture the structure well enough that someone reading only `design-brief.md` understands what the sample screen is composed of.

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
Keep prior phase composition entries. Add or update the current one under `## Screen Composition` using `### Phase [N] — [Screen Name]`. Do not delete an earlier composition merely because its preview is not the current phase's file. If an older entry lacks a phase label, preserve it unless the user explicitly asks to repair historical attribution; do not guess its phase.
<!-- /mano-rule: ui-phase-preview-ownership -->

### Step 3 — Generate HTML preview

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
Write the exact current-phase `PREVIEW` path from `state.js --ui`: `_mano_output/phase-[N]/design-preview.html`. It is one self-contained file with no external dependencies.

**Only include current-phase components and screen composition already described in the design brief.** The preview demonstrates what this phase agreed, not the project's full history or what might be needed later. Include the relevant colour and typography context, every component used by this phase's sample, and one representative screen mockup using real content from the phase brief.

Before writing, enforce the ownership boundary:
- The target must be inside the active `phase-[N]/` printed by the script.
- On a same-phase rerun, update only that phase's preview.
- Never create or edit `_mano_output/design-preview.html`.
- Never open, copy into, or edit another phase's preview.
<!-- /mano-rule: ui-phase-preview-ownership -->

### Step 4 — After Completion

Output a cold, structured execution log to the user indicating completion, pointing them to view the HTML preview or edit the brief. Use this exact format:

Use the canonical execution-log format defined in `_mano/workflow.md` ("Canonical execution-log format"):

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
```
[mano ui]: mano ui — _mano_output/design-brief.md, _mano_output/phase-[N]/design-preview.html
- Aesthetics: [brief summary of style/palette used or extended]
⚠ Verify: [embedded assumption worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano rules` — if project conventions, accessibility rules, or shared-component boundaries still need codifying
- `mano stories` — if the phase is already clear enough to break into implementable work
- `mano continue` — if you want Mano to pick only when there is a single obvious next step
```

If the phase has no design work to perform, use a skip log instead:

```text
[mano ui]: no design update — [comma-separated paths of existing design artifacts, or `no design artifacts`]
- Reason: [why the current phase needs no new or changed visual guidance]
```

List only files confirmed present by the projection and reads. Never print the current phase preview path in a skip log when that file does not exist.
<!-- /mano-rule: ui-phase-preview-ownership -->

Rules for the next-action block:
- Use the same block shape as `mano start` so the framework feels consistent across skills.
- Include only the Mano actions that are actually useful from the current artifact state after `mano ui`.
- Omit actions whose artifacts already exist and do not obviously need refinement.
- If only one next action is genuinely obvious, list just that one action plus `mano continue` only if it still adds value.
- If several next actions are valid, list them all instead of prescribing a fake sequence.
- Keep the one-line reason style used by `mano start`.

Do not ask for confirmation or add conversational fluff.

## When `mano ui` runs again

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
Re-run the state projection every time; phase identity is disk state, not conversation memory.

- **Later phase:** preserve the cumulative brief's still-valid guidance, add only current changes and its phase-labelled Screen Composition entry, and create the new phase's preview. Do not read or touch earlier previews.
- **Same phase:** read and update only the current phase preview plus the relevant parts of the cumulative brief.
- **No new components:** this is not by itself a reason to skip. If the phase introduces or changes a screen composition, or its required current-phase preview is missing, create/update the preview using the existing visual system.
- **Nothing design-relevant changed and the current preview already exists:** skip all writes and report that the current artifacts remain sufficient.
- **Phase has no UI or sample composition to clarify:** skip; a missing preview alone does not force optional design work onto a non-UI phase.
<!-- /mano-rule: ui-phase-preview-ownership -->

## Hard constraints

<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
- Keep the current visual system and component guide compact enough to review in under five minutes. Aim for roughly 500-900 words plus concise, phase-labelled Screen Composition entries; do not erase valid prior entries merely to meet the target.
- Each phase HTML preview is one self-contained file with no external dependencies.
<!-- /mano-rule: ui-phase-preview-ownership -->
- Make decisions, not suggestions. Every colour has a hex. Every size has a pixel value.
- Use real content from the phase brief in the sample mockup, not lorem ipsum.
- Preference capture must stay short. Do not turn `mano ui` into open-ended design discovery.

## Post-UI Hook Suggestion

After `mano ui` completes, always check whether this file exists:

`_mano/hooks/post-ui.md`

Ignore this file:

`_mano/hooks/post-ui.example.md`

If an active `post-ui.md` hook exists, prepare the generic hook block for the final chat response.

Do not run the hook automatically.

Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook.

This step is required even when no UI update was needed.

Mention it in the final chat response before the next-action block.

This applies whether the skill:
- created an artifact
- updated an artifact
- checked existing artifacts and decided no update was needed

Do not print the hook's suggested prompt unless the user asks to run or view the hook.
Do not execute the hook without explicit user confirmation.
Do not write hook suggestions into generated artifacts.

## Forbidden

- Do not generate per-screen wireframes beyond the single sample screen allowed in the HTML preview.
- Do not make product decisions — ask the user.
- Do not proactively suggest creating shared components via `mano rules` just because something in the design looks reusable. `mano ui` describes the UI; shared-component extraction is a project-rule decision that should surface only if the user asks or a missing rule is blocking clarity.
- Do not use external CDNs or network-dependent resources in the HTML preview.
<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
- Do not create, overwrite, delete, migrate, or use the legacy root `_mano_output/design-preview.html`.
- Do not read or edit a preview owned by another phase unless the user explicitly requests historical repair in a separate, narrowly scoped action.
<!-- /mano-rule: ui-phase-preview-ownership -->

## Backlog Boundary

`mano ui` does not read the backlog directly.

Backlog-level principles, including accessibility expectations, should be surfaced by `mano start` in the current phase brief when they are relevant to the design scope.

`mano ui` should rely on the phase brief, UX flow, design brief, project rules, and explicitly provided context.
