---
name: mano-ux
description: Use to define UX flows, navigation, and user interactions for visual screens and player-facing in-world interactions.
requires: [core, artifact]
requires-in-auto: [auto]
---

# `mano ux` — UX Flow Skill

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.


## Identity

This skill maps how people actually use the software — what they see, what they tap, where they go next. Prefix every message with `[mano ux]:`. No jargon, no developer-speak.

## Activation

This skill activates when the user types `mano ux`.
When inputs are missing, follow the missing-input protocol in `_mano/rules/core.md`.

Read this file plus `_mano/rules/core.md` and `_mano/rules/artifact.md` first — before the state projection, then artifacts — and read only those rule files; never open `_mano/workflow.md` mid-skill. Keeping that order stable keeps the contract prefix cacheable.

On activation:
1. Run `node _mano/scripts/state.js --current`. This is the only phase-directory discovery. If it fails, lacks `STATUS`, `MODE`, `OWNER`, `PHASE_ID`, `PHASE_DIR`, and `BRIEF`, or reports `STATUS: NO_PHASE`, stop and route to `mano start`. Never construct `phase-N` from the number.
2. Read the exact projected `BRIEF` path.
3. Read `_mano_output/ux-flow.md` if it exists.
4. Read `_mano_output/tech-spec.md` if it exists — know what's technically possible.
5. Read `_mano_output/project-rules.md` if it exists — respect a11y requirements (touch targets, contrast) that affect screen layout.
6. If the projected phase brief does not exist, stop and route to `mano start`. Do not write or offer to continue without it.

## Inputs

- Phase brief (required)
- Existing UX flow (if it exists — extend, don't regenerate)
- Tech spec (optional — constrains what's possible)
- `_mano_output/project-rules.md` (optional — a11y rules that affect layout)

## Role

Define how users move through the application or game. Generate the UX flow for the current phase only — new screens, changed screens, in-world interactions, and new navigation. Do not regenerate existing flows that haven't changed.

`mano ux` is responsible for reducing avoidable screen overload before it reaches story generation. If a single screen would otherwise carry too many primary actions or decisions, restructure the flow into smaller steps or companion screens within the same phase instead of documenting the overload as-is.

## Flow — One-Shot Generation

Generate the UX flow for the exact projected `PHASE_ID` entirely in one go and write it to `_mano_output/ux-flow.md` — a full-file write only when the file does not exist yet; when it exists, targeted replacements only, per `_mano/rules/core.md` → **Writing artifacts: create once, edit thereafter**. Immediately before writing, rerun `node _mano/scripts/state.js --current`; continue only if `OWNER`, `PHASE_ID`, `PHASE_DIR`, and `BRIEF` are unchanged. Do not pause for confirmation. Do not present screens one at a time in the chat. Make structural decisions based on the brief and enforce them.

### Step 1 — Define all screens & Navigation

Write the full navigation structure and screen definitions to the file.
If the file already exists, **extend it** — add new screens and update changed screens. Do not remove or regenerate screens that haven't changed. Do remove screens and states that no longer exist in the product: a screen that was cut, merged, or replaced should be deleted or replaced in place, not preserved as a dead entry. `ux-flow.md` describes current UX, not history. History lives in `reviews.md` and git.

Before writing or updating screens, normalise overloaded flows:
- Prefer one primary decision or action per screen or step. Two primary actions is the practical ceiling.
- Treat the same entity in different modes as one product flow when the UI shape and data contract are substantially the same. For example, add and edit on the same form can stay on one screen if edit is just the pre-populated form state of the same interaction.
- If a proposed screen combines distinct jobs such as select + edit, add + remove, review + jump-back editing, or manage + confirm, split that work into separate steps, screens, or subordinate flows in `ux-flow.md`.
- Keep the user's path straightforward. It is better to add one clear intermediate step than to preserve a dense screen that will later produce blurry ownership and oversized stories.
- Do not count basic navigation controls like back, close, or continue as primary actions unless they also perform meaningful data mutation or branching.
- If you keep a screen with two primary actions, make the ownership of each action obvious in the screen description.
- A management surface for one entity may keep closely related lifecycle actions together when they clearly belong to the same job. The overload concern starts when the screen also mixes in a separate branch, summary, confirmation, or unrelated decision.

For each screen, include:
- **How it's accessed:** [tab, opens from another screen, modal, bottom sheet, inline section]
- **How the user gets back:** [back button, close, swipe down, auto-dismiss]
- **What the user sees:** [key elements on this screen]
- **What the user can do:** [actions available]
- **What happens on action:** [result of each action]

Use plain language. "Tapping a todo on the list opens Todo Detail as a full screen. Back button returns to the list." Not "stack screen pushed from tab context."

For a player-facing game, an in-world/HUD interaction is a flow even when it opens no conventional screen. When two or more tools, buildables, abilities, modes, or rewards can be available at once, document: what makes each available; how the player invokes the choice; how they select or change it; how the active choice is communicated; what executing it does; and locked, unavailable, and cancel/back behaviour. Do not leave a hardcoded active item standing in for the player decision.

## Post-UX hook

If the state projection's `HOOK:` line names `post-ux`, follow `_mano/rules/hooks.md` for it. Otherwise skip hooks entirely — do not probe `_mano/hooks/` yourself. This check applies even when no UX update was needed.

## After completion

Output a cold, structured execution log to the user indicating completion, pointing them to edit the file directly if needed. Use the canonical execution-log format defined in `_mano/rules/core.md` ("Canonical execution-log format"):

```
[mano ux]: mano ux — _mano_output/ux-flow.md
- Screens/states updated: [list of screens or UX states added or modified]
⚠ Verify: [embedded assumption worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano ui` — if visual direction or component language still need defining
- `mano rules` — if project conventions or framework constraints still need codifying
- `mano stories` — if the phase is already clear enough to break into implementable work, and you want story files a small-context implementer works one at a time
- `mano build` — if the phase is already clear enough to break into implementable work, and you want it built straight from the brief with no story files
- `mano continue` — if you want Mano to pick only when there is a single obvious next step
```

The next-action block follows `_mano/rules/artifact.md` → **Next-step suggestion rule**. Do not add conversational fluff.

**Show both implementation paths in `manual`, and only `mano build` in `auto`.** `_mano/rules/artifact.md` → **Next-step suggestion rule** owns this: at the no-ledger planning stage the mode decides, so read `MODE:` from the projection rather than defaulting to whichever path the examples use most.

## Hard constraints

- During follow-up adjustments, discuss changed screens individually instead of regenerating unrelated screens.
- Do not leave a screen with more than two primary actions when `mano ux` can reasonably split it into clearer steps without changing the phase scope.
- If the phase brief appears to name one overloaded screen, `mano ux` may break it into multiple screens or steps as long as the product behaviour stays the same and the added structure is explained plainly.
- If a screen needs more than 8 bullet points, it's doing too much — flag it.
- Only include screens from the current phase brief. Do not add screens speculatively.
- Write in plain language a non-developer can understand.

## Forbidden

- Do not pick libraries or frameworks. That's `mano spec`'s job.
- Do not write stories. That's `mano stories`'s job.
- Do not design visual elements. That's `mano ui`'s job.
- Do not write or fix code. `mano ux` defines user flows.
- Do not add screens not in the current phase scope.
- Do not regenerate screens that haven't changed — extend only.
