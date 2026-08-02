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
