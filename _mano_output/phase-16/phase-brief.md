# Phase Brief — Anima — Phase 16

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

`Anima.on` and `Anima.grid` are complete convenience entry points, but `Anima.group` — the third one named in the product's own principles — still doesn't exist, and the chaining vocabulary around delay is inconsistent (per-leaf delay only, no whole-chain delay, no inline pause).

## Design Principle

Every convenience-API gap closed here should read like it was always part of the API, not bolted on — `Anima.group()` and the delay vocabulary must feel consistent with `Anima.on`/`Anima.grid`'s existing shape.

## Core Product Principles

- Relationships before timestamps: users describe "wait," "delay," "after this" — Anima calculates the schedule; the chain-level delay sugar exists so users never hand-compute per-leaf offsets.

## Phase Goal

A user can build a group animation via `Anima.group()`, delay an entire composed chain in one call, and insert an inline pause between chained steps — all through the same convenience surface as `Anima.on`/`Anima.grid`.

## Phase Scope

- `Anima.group()` convenience factory, accepting either a container Node (its children become the group's targets, matching `Anima.grid()`'s pattern) or an explicit array of target nodes
- A chain method that delays the start of an entire composed chain (built via `.then()`/`.with()`) in one call, without setting delay on every individual leaf
- A `.wait(seconds)` chain method that delays the start of whatever follows it in the chain, composing additively with an explicit per-child delay
- Internal composition/builder classes (`AnimaParallel`, `AnimaSequence`, and similar) renamed behind a non-public naming convention, so `Anima.on`/`Anima.group`/`Anima.grid` read as the intended entry points

## Not This Phase

- Reimplementing Anima v1's built-in animation library or an `animation` name/`.tres` keyword on `Anima.on`/`Anima.grid` (explicitly deferred in phase-15 scoping)
- Any new leaf/composite motion type, easing mode, or runtime capability beyond what `Anima.group()` needs to exist as a convenience factory
- Editor/Inspector-facing changes — this phase is code-API only

## Exit Criteria

1. Group convenience API
   - `Anima.group(%Container).move_by(...).play()` animates every child of `%Container`: works
   - `Anima.group([$A, $B, $C]).fade_in().play()` animates exactly those three nodes: works
2. Whole-chain delay
   - `Anima.on(%A).move_by(...).then(Anima.on(%B).fade_in())` composed, then played with a whole-chain delay: nothing starts until that delay elapses, both steps still run in their original order after it
3. Inline pause
   - `Anima.on(%A).move_by(...).wait(1.0).then(Anima.on(%B).fade_in())`: `%B`'s fade starts 1s after `%A`'s move completes
   - Same chain, with `%B`'s motion also given an explicit `with_delay(0.5)`: `%B` starts 1.5s after `%A`'s move completes
4. Internal surface
   - Autocomplete/class list for `Anima.*` convenience entry points no longer surfaces `AnimaParallel`/`AnimaSequence`/similar as equally-weighted public options

## Validation Plan

- **Decision this informs:** Whether the convenience API (`Anima.on`/`Anima.group`/`Anima.grid` plus the delay vocabulary) is complete enough to stop treating it as a moving target and start building real scenes on top of it.
- **Evidence to gather:** The user exercises `Anima.group()` and the new delay/wait chaining directly in a playground or showcase scene, same as prior phases.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| A single `Anima.group()` factory covering both a container-Node target and an explicit-array target is sufficient — no separate factory or mode flag is needed for the two forms. | If the two forms need materially different chaining/lifecycle behavior, `Anima.group()` may need to split into two entry points later, reworking call sites. |

## Acknowledged Risks

- Renaming internal builder classes touches code referenced by existing tests and possibly user-facing error messages (e.g. `_resolve_chainable`'s `type_string` output) — needs care to avoid breaking `.then()/.with()`'s duck-typed factory detection.
- "Whole-chain delay" and per-leaf `with_delay()` interacting with `.wait()` creates three additive delay mechanisms; the exact interaction semantics need precise definition in `mano spec` to avoid surprising double-delays.
