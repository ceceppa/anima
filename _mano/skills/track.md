---
name: mano-track
description: Use to show, set, or clear an optional local work track that groups a person's parallel experiments without replacing Source provenance or phase ownership.
---

# `mano track` — Work Track

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message.

Prefix every message with `[mano track]:`.

This optional setting groups a person's related experiments. It does not create an epic, change phase ownership, move existing work, or bypass scope/conflict checks.

## Activation

- `mano track` or `mano track show` → run `node _mano/scripts/track.js show`.
- `mano track "[name]"` or `mano track set "[name]"` → run `node _mano/scripts/track.js set "[name]"`.
- `mano track clear` → run `node _mano/scripts/track.js clear`.

Relay the script result and stop. If it fails, report the exact error; do not edit settings JSON, backlog items, or phase folders by hand.

## Contract

- Mode, track, remaining approved actions, skips, and repair attempts live in committed `_mano_output/[owner].json` files. Without an owner, they use `_mano_output/.default.json`. Only the selected owner stays in ignored `_mano_output/.local.json`. Environment variables override the stored values for a shell or worktree.
- Settings work without a Git checkout. Existing local Git config values migrate automatically when JSON state is missing; JSON takes precedence.
- `Source` remains provenance (document, review, or phase); `Track` is the direction or experiment (for example, `Option B`). Never replace one with the other.
- An active track tags newly imported backlog items and new items from `mano start`'s conversational intake. `mano start` considers only matching-track backlog items and records the track in its approved phase brief. Every review-created item copies that recorded phase track, even if the local setting changes later.
- Track is a candidate filter, not scope authority. Start still requires approval, and stories/dev still stop on phase, artifact, or contract conflicts.
- `mano track clear` affects future commands only. It never removes tracks already recorded in backlog items or phase briefs.

## Output

```text
[mano track]: [script result without its `[mano track]` prefix]
```
