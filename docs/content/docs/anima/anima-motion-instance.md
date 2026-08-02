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
