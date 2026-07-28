---
name: mano-ui
description: Use to establish the visual language, CSS/theme choices, and component guidelines.
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
1. Read the phase brief from `_mano_output/phase-[N]/phase-brief.md`.
2. Read `_mano_output/ux-flow.md` if it exists — know what screens and navigation exist before designing components.
3. Read `_mano_output/tech-spec.md` if it exists — constrains component library choices.
4. Read `_mano_output/project-rules.md` if it exists — respect any a11y requirements or component patterns already agreed.
5. Read design-relevant requirements only when they are included in the current phase brief, existing design brief, UX flow, project rules, or explicitly provided context.
6. Read `_mano_output/design-brief.md` if it exists — if already generated, use as foundation.
7. Check for missing inputs — if no phase brief exists, warn and ask if user wants to proceed.

## Inputs

- Phase brief (required — warn if missing)
- UX flow (recommended — `mano ui` should know what screens exist before designing)
- Tech spec (optional — constrains component library choices)
- `_mano_output/project-rules.md` (optional — a11y rules, component patterns)
- Existing `design-brief.md` (optional — extend, don't regenerate)

## Role

Establish the visual language for the project. Generate two files: a design brief (markdown) and a design preview (HTML). Generated once per project, extended only when needed.

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

Then component guide — **only include components that appear in the UX flow or phase brief.** Do not add components speculatively. If the UX flow has no dropdown, no dropdown in the guide. If there's no date picker in this phase, no date picker.

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

### Step 3 — Generate HTML preview

Write `_mano_output/design-preview.html` — single self-contained file, no external dependencies.

**Only include components and screen composition already described in the design brief.** The preview demonstrates what was agreed, not what might be needed later. Sections: colour swatches, typography, and every component from the guide above. Include one sample screen mockup using real content from the phase brief.

### Step 4 — After Completion

Output a cold, structured execution log to the user indicating completion, pointing them to view the HTML preview or edit the brief. Use this exact format:

Use the canonical execution-log format defined in `_mano/workflow.md` ("Canonical execution-log format"):

```
[mano ui]: mano ui — _mano_output/design-brief.md, _mano_output/design-preview.html
- Aesthetics: [brief summary of style/palette used or extended]
⚠ Verify: [embedded assumption worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano rules` — if project conventions, accessibility rules, or shared-component boundaries still need codifying
- `mano stories` — if the phase is already clear enough to break into implementable work
- `mano continue` — if you want Mano to pick only when there is a single obvious next step
```

Rules for the next-action block:
- Use the same block shape as `mano start` so the framework feels consistent across skills.
- Include only the Mano actions that are actually useful from the current artifact state after `mano ui`.
- Omit actions whose artifacts already exist and do not obviously need refinement.
- If only one next action is genuinely obvious, list just that one action plus `mano continue` only if it still adds value.
- If several next actions are valid, list them all instead of prescribing a fake sequence.
- Keep the one-line reason style used by `mano start`.

Do not ask for confirmation or add conversational fluff.

## When `mano ui` runs again

On subsequent phases, `mano ui` reads existing `design-brief.md` and checks if new components are needed. If nothing new, skip with a message. If extending, add new components without rewriting existing ones.

## Hard constraints

- Design brief + component guide should stay compact enough to review in under five minutes. Aim for roughly 500-900 words plus short component bullets.
- HTML preview is one self-contained file, no external dependencies.
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

## Backlog Boundary

`mano ui` does not read the backlog directly.

Backlog-level principles, including accessibility expectations, should be surfaced by `mano start` in the current phase brief when they are relevant to the design scope.

`mano ui` should rely on the phase brief, UX flow, design brief, project rules, and explicitly provided context.
