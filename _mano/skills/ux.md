---
name: mano-ux
description: Use to define UX flows, navigation, and user interactions for visual screens and player-facing in-world interactions.
requires: [core, artifact]
requires-in-auto: [auto]
---

# `mano ux` — UX Flow Skill

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message.

## Optionality boundary

This action is optional. Run it only when the current phase needs this kind of clarity or when existing artifacts are stale, missing, or too vague to support good stories. Reuse existing project context when it is still good enough; do not regenerate work just to follow a pipeline.


## Identity

This skill maps how people actually use the software — what they see, what they tap, where they go next. Prefix every message with `[mano ux]:`. No jargon, no developer-speak.

## Activation

This skill activates when the user types `mano ux`.
When inputs are missing, follow the missing-input protocol in `_mano/rules/core.md`.

Read this file plus `_mano/rules/core.md` and `_mano/rules/artifact.md` first — before the state projection, then artifacts — and read only those rule files; never open `_mano/workflow.md` mid-skill. Keeping that order stable keeps the contract prefix cacheable.

On activation:
1. Run `node _mano/scripts/state.js --gaps ux-gap`. Its `GAP INPUT` is the complete backlog-derived context for open UX gaps: only unresolved `ux-gap` items are exposed. **Do not open `_mano_output/backlog.md` before or after this command.** If the command fails or its output lacks the `GAP INPUT`, exact `MODE:`, `TYPE: ux-gap`, `STATUS: backlog`, and `COUNT:` lines, stop and report the exact failure.
2. Run `node _mano/scripts/state.js --current`. This is the only phase-directory discovery. If it fails or lacks `STATUS`, `MODE`, `OWNER`, `PHASE_ID`, `PHASE_DIR`, and `BRIEF`, stop and report the exact failure. Never construct `phase-N` from the number.
3. Read the exact projected `BRIEF` path when one exists.
4. Read `_mano_output/ux-flow.md` if it exists.
5. Read `_mano_output/tech-spec.md` if it exists — know what's technically possible.
6. Read `_mano_output/project-rules.md` if it exists — respect a11y requirements (touch targets, contrast) that affect screen layout.
7. **No phase brief → gap-only mode, or stop.** If `STATUS: NO_PHASE` or the projected brief does not exist, check `COUNT:` from step 1. `COUNT: 0` and no directive written with the command → stop; there is nothing to do and nothing to write (see **Directive mode** for the stop message). `COUNT:` above zero → run **Gap-only mode** below. A directive written with the command, including a contract for one feature, → run **Directive mode** below. Do not scope a phase, and do not invent or extend screens nobody asked for.

## Gap-only mode

`ux-flow.md` is a cumulative project artifact, not a per-phase one. A `ux-gap` says something already proved it wrong or incomplete — a rework that changed a flow, a review finding nobody homed — and that repair must not wait for the next phase to be scoped. It cannot wait: an open gap blocks `mano start` from scoping one, so a `ux-gap` that needed a phase brief would deadlock the loop it was meant to close.

In gap-only mode:

- Work **only** the projected `ux-gap` items. Do not add, extend, or restructure any screen no projected gap names.
- Repair `_mano_output/ux-flow.md` with targeted replacements, per `_mano/rules/core.md` → **Writing artifacts: create once, edit thereafter**. Never a full-file regeneration.
- A gap item may carry a stated directive rather than an open question — the human's own words about how a flow must work. That is authoritative intent: adopt it as written, or override it explicitly with the reason in the completion log, never silently.
- Write **no** phase preview and **no** phase-scoped content. There is no phase.
- Resolve each item the flow now addresses, one call per item:

```
node _mano/scripts/backlog.js resolve-gap --type ux-gap --title "[exact projected title]"
```

- Resolve an item only once `ux-flow.md` actually adopts or explicitly overrides it. If a projected gap turns out to need a decision only the human can make, leave it open, and surface it as a `❓ Decide:` line — an unresolved gap keeps `mano start` blocked, which is the correct outcome while a UX decision is genuinely pending.
- Close with the canonical execution log, then `Next:` — `mano start` when no gap remains, otherwise the skills the remaining routes name.

## Directive mode

A project-wide UX rule the human writes with the command — `mano ux "every destructive action asks for confirmation"` — is input this skill owns, with or without a phase. `ux-flow.md` is cumulative, so the UX rule needs no phase brief to justify it, and it needs no backlog item to survive a context reset: once written here, this file is its home. Recording it as a `ux-gap` first would only make the human approve a row restating what they just said.

- **It is a directive when** it states a rule this file owns that holds across the whole product: a navigation rule, a step every flow of a kind must include, a required empty, error, or recovery state, a global interaction pattern. It is authoritative intent: adopt it as written, or override it explicitly with the reason in the completion log and a `❓ Decide:` line — never silently.
- **Not this skill's → route it verbatim and write nothing.** A folder, naming, or code convention → `mano rules "[the directive]"`; a stack or value decision → `mano spec "[the directive]"`; a visual treatment → `mano ui "[the directive]"`. The flow for one feature or screen is this skill's too: see **A contract for one feature** below.
- **With no phase**, it runs under every Gap-only mode bound above: write only what the directive decides, nothing phase-scoped, no phase directory. Settle any projected `ux-gap` items in the same run. With a phase, the directive is applied alongside the phase's own work, as a project-wide rule.
- **No backlog write for the directive.** Create no gap item for it and resolve none on its behalf; a projected gap it happens to settle is resolved the normal way.
- **Contract, not code.** Writing the rule does not change screens already built. When it constrains flows earlier phases shipped, add one `⚠ Verify:` line: existing screens are not retrofitted by this run, and bringing them in line is implementation work → `mano start`. Do not read source to find them.
- **Bare `mano ux` with no phase, no projected gap, and no directive** → stop and write nothing. Say there is no phase to work on, and name both ways in: `mano start` for phase work, or `mano ux "[the rule]"` to fix a project-wide UX rule now.

### A contract for one feature

The human may hand this skill the flow for one feature or screen, to be built now, later, or never: `mano ux "batch rename: pick several items, rename them in one dialog; cancelling keeps the old names"`. Writing it is this skill's job, with or without a phase, and after the latest phase has closed. Whether and when it gets built is the human's call. Refusing it because no phase is open, because the last phase is reviewed, or because it describes a feature overrides that call.

- **Write what the words decide** into the existing `ux-flow.md` structure. Settle the details a UX designer would settle inside those words (entry point, back path, empty and error states) from the flows already in the file. Ask once, numbered, only about a choice that changes what the user does and that neither the words nor the file settle.
- **The request wins over the file.** When it contradicts what `ux-flow.md` says, it is the newer decision: replace the old statement in place, never leave both standing, and log both (`Replaced: <old> → <new>`). Raise `❓ Decide:` only when the words could equally mean replacing the old statement or sitting beside it.
- **Same bounds as Directive mode.** No phase preview, no phase directory, no backlog write. Route any part another owner decides, verbatim.
- **Contract, not code.** Add one `⚠ Verify:` line: this run builds nothing, and building it is work. `Next:` is `mano task "<item title>"` when the words name a backlog item, as they do when `mano task` routed here. Otherwise it is `mano task` or `mano start`, whichever the human picks to build it.
- **Nothing to decide, nothing to write.** A request that only asks for code to change ("fix the crash on save") has no flow in it. Write nothing and route it to `mano task` or `mano start`.

**With a phase brief present, projected `ux-gap` items are still in scope.** Address them in the same run as the phase's own screens and resolve each one the same way. A gap left open blocks the next `mano start`, so never defer one on the grounds that the phase's own work came first.

**Artifact resolution is not implementation completion.** Apply `_mano/rules/backlog.md` → **Artifact gaps versus implementation work**. Updating `ux-flow.md` never ships a requested product change. If a legacy projected gap actually contains unimplemented work, do not mark it resolved merely because the artifact now describes it. Report the exact title and route to `mano review` to propose a scopeable replacement and rejection of the misclassified gap; do not write application code in gap-only mode.

## Inputs

- Projected `ux-gap` items (required — from `state.js --gaps ux-gap`)
- Phase brief (required, except in **Gap-only mode**)
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

For new suggestions outside a saved chain: **Show both implementation paths in `manual`, and only `mano build` in `auto`.** In an armed chain, follow `CONTINUE_ACTION` and preserve `CHAIN_REMAINING`, which omits `stories` and ends at `build` when neither ledger exists; never skip its pending artifact actions. Only an existing stories ledger retains `dev`. `_mano/rules/artifact.md` → **Next-step suggestion rule** owns this: at the no-ledger planning stage the mode decides, so read `MODE:` from the projection rather than defaulting to whichever path the examples use most.

**A mid-chain hand-off prints no `Next:` block at all.** That rule is `_mano/rules/core.md` → **Canonical execution-log format** and `_mano/rules/auto.md` → **Continuing is an action, not an announcement**, and it outranks the sentence above: mid-chain nobody is choosing a command, so rendering `mano build` as an option and then running it yourself is a log that offers a choice and walks past it in the same breath — the exact shape that ends chains. The mode rule decides what a `Next:` block *contains* when there is one: on every `manual` run, and on the action that ends a chain.

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
