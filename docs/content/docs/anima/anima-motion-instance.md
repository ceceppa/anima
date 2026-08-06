---
title: "AnimaMotionInstance"
description: "Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]"
---

# AnimaMotionInstance

## Overview

Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]
returns. [method advance] is the shared per-frame contract every subtype implements.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### motion

The motion resource this instance is advancing.

### value_context

The per-resolution context an [AnimaValue]-typed field resolves against,
supplied by [method AnimaMotion.create_runtime]. `null` for an instance
built with no context — see [method _resolve_dynamic]'s fallback.

## Methods

### advance

Advances playback by delta seconds and applies the motion's effect to target.
Returns true once the motion has finished.

### build_reversed

Builds a new [AnimaMotion] that reverses this instance's actually resolved
run, for [method AnimaPlayback.reverse] on a non-group motion. Returns
`null` when this instance has not captured a start value yet (nothing to
reverse to) or when this motion kind does not support the generic reverse
path. Overridden by [AnimaPropertyMotionInstance], [AnimaSequenceInstance],
and [AnimaParallelInstance].

### restore_initial

Restores [param target] to the value captured when this instance began
advancing, for [method AnimaPlayback.revert] and a
[constant AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL] /
[constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL] outcome. A
no-op by default — every subtype overrides this explicitly (see
[AnimaPropertyMotionInstance], [AnimaSequenceInstance], [AnimaParallelInstance]).

### force_complete

Forces this instance to its valid final state immediately, applying every
active leaf's authored end value(s) — for [method AnimaPlayback.complete]
and a [constant AnimaMotion.CancellationValuePolicy.COMPLETE] outcome. A
no-op by default — every subtype overrides this explicitly.
