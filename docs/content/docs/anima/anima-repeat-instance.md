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
delay_between and starts the next repetition, or completes if that was the last one.
