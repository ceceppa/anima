---
title: "AnimaConditional"
description: "Selects between [member when_true] and [member when_false] based on"
---

# AnimaConditional

## Overview

Selects between [member when_true] and [member when_false] based on
[member condition], evaluated once per [method create_runtime] call.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### ResolutionTiming

When [member condition] is evaluated.

## Properties and constants

### when_true

Motion played when [member condition] returns `true`.

### when_false

Motion played when [member condition] returns `true`.
Motion played when [member condition] returns `false`.

### condition

Motion played when [member condition] returns `true`.
Motion played when [member condition] returns `false`.
Zero-argument [Callable] returning a [bool] that picks the branch.

### resolution_timing

Motion played when [member condition] returns `true`.
Motion played when [member condition] returns `false`.
Zero-argument [Callable] returning a [bool] that picks the branch.
When [member condition] is evaluated.

## Methods

### estimate_duration

COMPILE_TIME: resolves now and defers to the selected branch's own
AnimaDuration. RUNTIME (default): reports Dynamic without evaluating
`condition` — the branch isn't chosen until create_runtime() plays it.

### create_runtime

Builds the runtime instance, selecting the branch once (see [method _select_branch]).

### validate

Requires [member condition], [member when_true], and [member when_false].
