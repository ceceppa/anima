---
title: "AnimaPropertyMotion"
description: "Animates a single property on a node from one value to another. The only"
---

# AnimaPropertyMotion

## Overview

Animates a single property on a node from one value to another. The only
leaf motion type — every composite eventually plays one of these.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### target_property

The property to animate, e.g. `NodePath("position:x")`.

### from_value

The property to animate, e.g. `NodePath("position:x")`.
Starting value. `null` reads the target's current value when playback starts.

### to_value

The property to animate, e.g. `NodePath("position:x")`.
Starting value. `null` reads the target's current value when playback starts.
Value to animate to.

### duration

The property to animate, e.g. `NodePath("position:x")`.
Starting value. `null` reads the target's current value when playback starts.
Value to animate to.
How long the motion takes, in seconds. Unused when [member ease] is
[constant AnimaEase.Kind.SPRING] — a spring settles on its own instead.

### ease

The property to animate, e.g. `NodePath("position:x")`.
Starting value. `null` reads the target's current value when playback starts.
Value to animate to.
How long the motion takes, in seconds. Unused when [member ease] is
[constant AnimaEase.Kind.SPRING] — a spring settles on its own instead.
The curve (or spring) driving the animation.

## Methods

### estimate_duration

`FIXED` for every ease except [constant AnimaEase.Kind.SPRING], which
reports `ESTIMATED` (a settle-time estimate derived from its parameters).

### create_runtime

Builds the runtime instance that animates [member target_property].

### validate

Requires [member target_property].

### with_duration

Chainable setters for the Motion builder API. Named with_duration/with_ease
rather than duration/ease — those names are already the field names above,
and GDScript cannot declare a method with the same name as a property.

### with_ease

See [method with_duration].
