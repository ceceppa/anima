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

Advances every active child, then completes per completion_policy — all of
them, or just the one tracked at [member _completion_index]. A child whose
own [member AnimaMotion.delay] hasn't elapsed yet (relative to this
parallel's own start — [member AnimaMotion.delay_basis] does not apply
here, there being no "previous" child in an unordered group) doesn't start
until it does. Fires each newly-started/newly-finished child's own
callbacks — see [method _init] for the immediate-start case.

### restore_initial

Restores every started child's own captured initial value (see [method
AnimaMotionInstance.restore_initial]) — safe even for a child that never
captured one, since each subtype's own override guards that internally.
A child that never started (still waiting on its own delay) has nothing
to restore.

### force_complete

Forces every child to its own final state together — see [method
AnimaMotionInstance.force_complete]. Applies to every child regardless of
[member AnimaParallel.completion_policy], since completing the group
visually means every animating property reaches its authored end state,
not only the one tracked child that would otherwise decide completion.
Starts any not-yet-started (still delayed) child first, then fires each
newly-started/newly-finished child's own callbacks, same as [method advance].

### build_reversed

Builds a reversed [AnimaParallel]: every child that captured a start value
gets its own reversed motion, still played together. `null` when no child
has captured one yet.
