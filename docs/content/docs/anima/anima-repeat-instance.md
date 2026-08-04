---
title: "AnimaRepeatInstance"
description: "Runtime instance for [AnimaRepeat] — replays [member AnimaRepeat.child]"
---

# AnimaRepeatInstance

## Overview

Runtime instance for [AnimaRepeat] — replays [member AnimaRepeat.child]
[member AnimaRepeat.count] times, with an optional delay between repetitions.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances the current repetition; once it finishes, either waits out
delay_between and starts the next repetition, or completes if that was the
last one. A negative [member AnimaRepeat.count] never completes on its own.

### restore_initial

Restores the current iteration's own captured initial value — see [method
AnimaMotionInstance.restore_initial].

### force_complete

Forces the current iteration to its final state — a repeat's own notion of
"complete" is the current iteration reaching its end, not exhausting
[member AnimaRepeat.count] (which may be indefinite) — see [method
AnimaMotionInstance.force_complete].

### build_reversed

Builds a reversed [AnimaRepeat]: the currently-active iteration's own
reversed motion (see [method AnimaMotionInstance.build_reversed]), repeated
the same [member AnimaRepeat.count] times with the same [member
AnimaRepeat.delay_between] and [member AnimaRepeat.alternate] — the same
"freshly built reversed motion, restart from the top" rule already applied
to a leaf/[AnimaSequence]/[AnimaParallel] reversal, extended to [AnimaRepeat]
instead of carved out as a special case. `null` before any iteration has
captured a value yet.
