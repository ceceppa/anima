---
title: "AnimaNodeProxy"
description: "Lightweight proxy returned by [method Anima.of] — animates a single node"
---

# AnimaNodeProxy

## Overview

Lightweight proxy returned by [method Anima.of] — animates a single node
directly, without the caller building an [AnimaMotion] resource by hand.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### DEFAULT_DURATION

Default duration used by [method to] / [method transition_to] / [method enter]
/ [method exit] when the caller doesn't provide one.

### target

The node this proxy animates.

## Methods

### default_ease

The default ease ([constant AnimaEase.Kind.SINE]) used when the caller
doesn't provide one. A GDScript `const` can't hold a Resource instance, so
this is a factory returning a fresh instance per call rather than a shared
constant.

### to

Animates a single [param property] on [member target] to [param to_value].

### transition_to

Animates every property in [param properties] (`{NodePath: Variant}`) on
[member target] together, completing when the slowest one does.

### enter

Fades [member target] in (`modulate:a` from `0.0` to `1.0`) using a
built-in default motion. Reading `motion_in` from an attached
[code]AnimaBehaviour[/code] instead is separate, later work.

### exit

Fades [member target] out (`modulate:a` toward `0.0`) using the same
built-in default as [method enter], in reverse.
