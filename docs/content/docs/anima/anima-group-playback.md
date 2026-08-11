---
title: "AnimaGroupPlayback"
description: "Runtime instance for [AnimaGroupMotion] — resolves its target collection"
---

# AnimaGroupPlayback

## Overview

Runtime instance for [AnimaGroupMotion] — resolves its target collection
once, derives a schedule, then advances every resolved target's own item
motion according to the group's playback mode.

Created automatically by [method AnimaGroupMotion.create_runtime]; not
something you construct directly. Reach a running group through the
[AnimaPlayback] [method Anima.play] returns — [member
AnimaPlayback.speed_scale] and [method AnimaPlayback.reverse] are the
supported ways to control one from outside.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### execution_record

The recorded schedule for this execution, available once resolution has
happened (the first [method advance] call) — `null` before that.

## Methods

### advance

Advances every active item by [param delta]. [param target] is the root
node that target-collection kinds like Children resolve against (or [member
AnimaMotion.convenience_target] when set — see [method _effective_target]);
resolution itself only happens once, on the first call. A composite
combining leaves captured against different targets has no single root for
[AnimaPlayback]'s own freed-target check to guard (§Lifecycle-safe playback
policies) — this per-instance [method is_instance_valid] check is that same
protection applied here too, mirroring [method
AnimaPropertyMotionInstance.advance]'s own equivalent guard.

### restart_from_record

Restarts this playback from [param record] instead of resolving and
scheduling again. Used by [method AnimaPlayback.reverse] so a reverse
replays the exact recorded sequence rather than a fresh — and
potentially different — resolution. [param reversed_item_motions] is the
per-target map [method build_reversed_item_motions] produced from the run
being reversed; a target missing from it plays the ordinary forward
[member AnimaGroupMotion.item_motion] instead (it never started, so it has
nothing of its own to reverse to).

### build_reversed_item_motions

Builds a per-target map of each started item's own reversed motion (see
[method AnimaMotionInstance.build_reversed]), for [method AnimaPlayback.reverse]
to hand to a fresh [method restart_from_record] call so each item replays
backward to what it actually started from, instead of repeating its
original forward motion. A target that never started this run has no
entry — there is nothing captured to reverse it to.

### restore_initial

Restores every started item's own captured initial value on its own
resolved target — [param _target] is ignored, the same way [method advance]'s
root only matters for resolution, which has already happened by the time
anything has started.

### force_complete

Forces every resolved item to its own final state, regardless of [member
AnimaGroupMotion.completion_policy] — completing the group visually means
every item reaches its authored end state, not only the one item that
would otherwise decide completion.
