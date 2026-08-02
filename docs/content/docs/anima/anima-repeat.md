---
title: "AnimaRepeat"
description: "Repeats [member child] [member count] times, with an optional delay between"
---

# AnimaRepeat

## Overview

Repeats [member child] [member count] times, with an optional delay between
repeats and an alternating (ping-pong) mode.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### child

The motion to repeat.

### count

How many times [member child] plays. Always finite this phase.

### delay_between

Delay in seconds between one repetition ending and the next starting.

### alternate

When `true`, odd repetitions reverse [member child] (swap `from_value`/
`to_value` for an [AnimaPropertyMotion] child) instead of repeating it
identically.

## Methods

### estimate_duration

Sums [member child]'s duration across every repetition plus the delays
between them, once [member child] itself reports a fixed duration.

### create_runtime

Builds the runtime instance that replays [member child].

### validate

Requires [member child].
