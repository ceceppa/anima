---
title: "AnimaPropertyMotionInstance"
description: "Runtime instance for [AnimaPropertyMotion] — animates one property toward"
---

# AnimaPropertyMotionInstance

## Overview

Runtime instance for [AnimaPropertyMotion] — animates one property toward
its target value each frame, via a normalized-time curve for most eases or
a stateful physics simulation for [constant AnimaEase.Kind.SPRING].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances this motion by [param delta] seconds and writes the new value to
[param target]. Returns `true` once finished.

### build_reversed

Builds a new [AnimaPropertyMotion] that reverses this instance's actually
resolved run — the captured start and effective end values swapped, so
reverse playback returns to what was actually observed at start, even for
a relative (`move_by`-style) motion. `null` before any value is captured.

### restore_initial

Restores [param target]'s property to the value captured when this
instance began advancing. A no-op if nothing has been captured yet.

### force_complete

Applies this motion's authored end value to [param target] immediately —
capturing a start value first (a zero-length advance) if nothing has been
captured yet. A SPRING-eased motion is force-settled to its spring target
instead, since it has no fixed to-value curve.

### retarget_spring

Redirects a still-moving spring to a new destination, preserving its
current value/velocity instead of resetting them (see [method AnimaPlayback.retarget]).
Restarts the elapsed clock so FIXED_PREVIEW_DURATION measures from the retarget point.
