---
title: "AnimaParallelInstance"
description: "Runtime instance for [AnimaParallel] — advances every enabled child each"
---

# AnimaParallelInstance

## Overview

Runtime instance for [AnimaParallel] — advances every enabled child each
frame and completes per its [member AnimaParallel.completion_policy].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances every unfinished child, then completes per completion_policy —
all of them, or just the one tracked at [member _completion_index].

### restore_initial

Restores every child's own captured initial value (see [method
AnimaMotionInstance.restore_initial]) — safe even for a child that never
captured one, since each subtype's own override guards that internally.

### force_complete

Forces every child to its own final state together — see [method
AnimaMotionInstance.force_complete]. Applies to every child regardless of
[member AnimaParallel.completion_policy], since completing the group
visually means every animating property reaches its authored end state,
not only the one tracked child that would otherwise decide completion.

### build_reversed

Builds a reversed [AnimaParallel]: every child that captured a start value
gets its own reversed motion, still played together. `null` when no child
has captured one yet.
