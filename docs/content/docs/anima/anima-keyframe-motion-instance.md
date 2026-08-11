---
title: "AnimaKeyframeMotionInstance"
description: "Runtime instance for [AnimaKeyframeMotion] — advances every track together"
---

# AnimaKeyframeMotionInstance

## Overview

Runtime instance for [AnimaKeyframeMotion] — advances every track together
against one shared elapsed clock, evaluating each independently.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances this motion by [param delta] seconds and writes every track's
current value to [param target] — or [member AnimaMotion.convenience_target]
when set (see [method _effective_target]). Returns `true` once finished.

### restore_initial

Restores every track's starting value — for [method AnimaPlayback.revert]
and a [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL]
outcome. Resolves first if nothing has advanced yet, the same way [method
force_complete] does, so a dynamic-valued stop is never applied unresolved.

### force_complete

Forces every track to its authored end value immediately — for [method
AnimaPlayback.complete] and a [constant AnimaMotion.CompletionValuePolicy]
outcome; resolves first if nothing has advanced yet (see [method restore_initial]).

### build_reversed

Builds a reversed [AnimaKeyframeMotion]: every stop's offset becomes
`1.0 - offset`, but easing *ownership* also shifts by one stop, not just
mirrors in place — the segment that used to run `stop_i -> stop_{i+1}`
(eased by `stop_{i+1}`'s effective easing) now runs the other way, so the
easing moves to the new stop built from `stop_i`, mirrored. Walking the
original stops from last to first already produces offset-ascending order
once transformed, so no separate sort is needed. Unlike a captured-value
reversal, nothing needs to have played yet — every value a keyframe motion
needs is already in its authored tracks.
