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
node that target-collection kinds like Children resolve against;
resolution itself only happens once, on the first call.

### restart_from_record

Restarts this playback from [param record] instead of resolving and
scheduling again. Used by [method AnimaPlayback.reverse] so a reverse
replays the exact recorded sequence rather than a fresh — and
potentially different — resolution.
