---
title: "AnimaRuntime"
description: "Lazily-created runtime singleton that owns the central per-frame evaluation"
---

# AnimaRuntime

## Overview

Lazily-created runtime singleton that owns the central per-frame evaluation
loop. No [code]project.godot[/code] autoload entry required — see
[method get_singleton].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### active_playbacks

Every playback currently in progress.

## Methods

### get_singleton

Returns the lazily-created runtime instance, creating it on first call.

### play

Starts playing [param motion] against [param target] and tracks it in
[member active_playbacks] until it finishes.

### play_backwards

Same as [method play], except playback begins already running backward —
see [method AnimaPlayback._init]'s `p_start_reversed` and [method Anima.play_backwards].

### ensure_tracked

Re-adds [param playback] to [member active_playbacks] if it isn't already
there. A playback that already finished or was cancelled was removed (see
[method _track]) so it stops being advanced every frame; [method
AnimaPlayback.reverse] calls this to resume being ticked after it sets the
playback back to [constant AnimaPlayback.State.PLAYING] — otherwise
nothing would ever call [method AnimaPlayback._advance] on it again.
