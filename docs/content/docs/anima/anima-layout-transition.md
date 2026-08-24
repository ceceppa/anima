---
title: "AnimaLayoutTransition"
description: "Runtime-only record for one supported Control-container layout change."
---

# AnimaLayoutTransition

## Overview

Runtime-only record for one supported Control-container layout change.
Capture the controls before asking Godot to relayout, then call [method play]
after the container has selected its final rectangles.  The final rectangles
remain the only destination values; this record only makes the change visible
between the two layouts.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### DEFAULT_DURATION

Default duration in seconds for a captured layout transition.

## Methods

### play

Returns the playbacks started when Godot changed the captured layout.
