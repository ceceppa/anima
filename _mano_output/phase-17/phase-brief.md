# Phase Brief — Anima — Phase 17

## Why This Phase

Anima 2 has no built-in animation catalog yet — every user has to hand-compose motions from scratch. V1 shipped 99 ready-to-use animations; bringing them forward gives Anima 2 immediate parity and a usable out-of-the-box library.

## Design Principle

Ship v1's full catalog with no triage — completeness over curation for this pass.

## Core Product Principles

- Static motion compiles, dynamic motion stays dynamic — v1's dynamic-expression formulas must resolve through the existing runtime-state mechanism, not a separate parser.
- One data model, multiple authoring surfaces — every ported animation must produce the same underlying motion resource whether reached by name or by asset file.

## Phase Goal

A user can call any of the 99 v1 animations by name or use its resource file directly, and get the same visual behaviour v1 produced — including animations whose values depend on the target's own runtime state.

## Phase Scope

- All 99 v1 animation definitions ported across their existing categories: attention, back entrances/exits, bouncing entrances/exits, fading entrances/exits, lightspeed, rotating entrances/exits, sliding entrances/exits, specials, text, zooming entrances/exits.
- Each ported animation is reachable two ways: by name through a lookup call, and as a standalone asset a user can reference directly.
- Animations grouped into named categories so the catalog is browsable/discoverable, not a flat list.
- Any v1 animation whose values were computed from runtime state (the target's own size/position, etc.) is rebuilt so those values still resolve dynamically at play time — not baked to fixed numbers.

## Not This Phase

- No preset browser UI, search, tags, or favourites (existing separate backlog item).
- No per-preset keep/rename/deprecate/remove triage — every v1 animation ships as-is.
- No motion themes, project-level defaults, or reduced-motion alternative authoring for the catalog (existing separate backlog items).
- No Easing Studio or curve-preview tooling.

## Exit Criteria

1. Catalog reachable by name
   - User calls the by-name lookup for an animation in each of the 10 style groups: each produces the same visual motion as the corresponding v1 animation.
2. Catalog reachable by asset
   - User drags/references the resource file for the same animation directly (no name lookup): identical result to the by-name call.
3. Dynamic values preserved
   - An animation whose v1 source used a runtime formula (e.g. a translate offset computed from the target's own size and position) still computes that value from the live target at play time, not a value frozen at author time.
4. Full coverage
   - Every one of the 99 v1 source files has a corresponding Phase 17 animation; none silently dropped.

## Validation Plan

### Questions

- Does the ported catalog match v1's visual/timing behaviour across every category, not just a few representative ones?
- Does reaching an animation by name feel as easy to remember as v1's lookup did?

### Try

- Play each category's ported animations against the v1 addon (or a recorded reference) side by side and compare timing and end values.
- Call the by-name lookup for a handful of animations from a scratch scene during review and judge whether the naming reads naturally.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The category taxonomy used to group these 99 presets is sufficient for this phase's discoverability need, even though the full preset browser (deferred) may later impose its own taxonomy/filtering requirements. | The browser lands and needs categories reshaped, forcing a second pass over all 99 entries. |

## Acknowledged Risks

- 99 animations is a large, mechanical porting effort — a missed or subtly-wrong one may not surface until someone reaches for that specific animation.
- Dynamic-value formulas are the highest-risk subset: a mistranslation from v1's string-expression syntax to the typed resolver could silently produce a static value instead of a live one.

## Stated Technical Preferences

<!-- Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override. -->

- "These needs to be rewritten with the new AnimaValue way" — re: v1 dynamic formulas like `"translate:x": ":size:x + :position:x"`.
- "let's use Anima.animation instead of `preset` as animation is easier to remember (unless you have a stronger / better preference)"
