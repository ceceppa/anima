---
name: mano-language
description: Use to show, set, or clear the languages Mano uses for conversation (chat), implementation content (build), and planning artifacts (artefacts).
---

# `mano language` — Languages

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message.

Prefix every message with `[mano language]:`.

This command sets which languages later commands use. It does not translate, create, or edit any planning artifact or source file.

## Activation

- `mano language` or `mano language show` → run `node _mano/scripts/language.js show`.
- `mano language [channel] "[language]"`, optionally repeated (for example `mano language chat it build en-GB artefacts it`), or the same after `set` → run `node _mano/scripts/language.js set [channel] "[language]" ...` with every pair in one call. A channel is `chat`, `build`, or `artefacts`.
- `mano language clear` (all three) or `mano language clear [channel ...]` → run `node _mano/scripts/language.js clear [channel ...]`.

Every language needs its channel. A bare `mano language it` is refused by the script on purpose: relay its error and ask which channel or channels the human means; never pick one, or all three, yourself. Pass each language value through as typed (a name such as `Italian` or a locale tag such as `en-GB`); never normalise or translate it. If the request names languages in prose with clear channels (for example "speak Italian, but write the code in UK English"), map each part to its channel and run one `set` with those pairs.

Relay the script result and stop. If it fails, report the exact error; do not edit settings JSON by hand. A successful change takes effect immediately: re-run the language check and write the result message in the new `language.chat`.

## Contract

- `chat` controls conversation; `build` controls implementation content (code, comments, tests, product documentation, and product/UI text); `artefacts` controls new planning prose. An unset `artefacts` follows `build`, then `chat`.
- Languages live with the other settings in committed `_mano_output/[owner].json` files. Without an owner, they use `_mano_output/.default.json`. The script creates the file when it does not exist yet.
- Changing a language affects future writes only. Never translate existing artifacts, stories, or code because the setting changed.

## Output

```text
[mano language]: [script result without its `[mano language]` prefix]
```
