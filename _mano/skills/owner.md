---
name: mano-owner
description: Use to show, set, or clear the local owner slug that opts this repository clone into owner-scoped Mano phases for parallel team work.
---

# `mano owner` — Phase Ownership

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message.

Prefix every message with `[mano owner]:`.

This command configures routing; it does not create, rename, migrate, scope, or close a phase.

## Activation

- `mano owner` or `mano owner show` → run `node _mano/scripts/owner.js show`.
- `mano owner <slug>` or `mano owner set <slug>` → run `node _mano/scripts/owner.js set <slug>`.
- `mano owner clear` → run `node _mano/scripts/owner.js clear`.

Relay the script result and stop. If it fails, report the exact error; do not edit settings JSON or phase folders by hand.

## Contract

- Ownership is opt-in. With no configured slug, all phase-scoped commands keep using legacy `_mano_output/phase-N/` folders and `in-phase-N` backlog statuses.
- With a configured slug such as `alice`, phase-scoped commands use `_mano_output/alice-phase-N/` and `in-alice-phase-N` within that owner's independent number sequence.
- The slug is a stable team handle, not `whoami`, a machine account, or an email address.
- Mode, track, remaining approved actions, skips, and repair attempts live in committed `_mano_output/[owner].json` files. Without an owner, they use `_mano_output/.default.json`. Only the selected owner stays in ignored `_mano_output/.local.json`. Environment variables override the stored values for a shell or worktree.
- Settings work without a Git checkout. Existing local Git config values migrate automatically when JSON state is missing; JSON takes precedence.
- Two people may configure the same slug to hand over or pair on the same phase. Different slugs select independent phase sequences.
- Clearing the slug returns this repository clone to legacy `phase-N` routing. Existing owned folders remain untouched.
- Ownership selects work; it does not provide merge isolation. Teammates still use branches/worktrees and coordinate changes to shared backlog, spec, rules, design, and review files.

## Output

```text
[mano owner]: [script result without its `[mano owner]` prefix]
```
