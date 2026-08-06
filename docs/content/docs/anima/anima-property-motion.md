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

## Enumerations

### Pivot

Restored Anima v1 anchor positions a scale or rotation motion can
transform around, instead of the target's default origin. Only takes
effect when [member target_property] is `scale`/`scale:x`/`scale:y` or
`rotation` — see [member pivot] (`tech-spec.md` §Motion pivot control).

## Properties and constants

### target_property

The property to animate, e.g. `NodePath("position:x")`.

### from_value

Starting value. `null` reads the target's current value when playback starts.

### to_value

Value to animate to. Interpreted as an absolute destination, unless
[member relative] is `true` — see [member relative].

### duration

How long the motion takes, in seconds. Unused when [member ease] is
[constant AnimaEase.Kind.SPRING] — a spring settles on its own instead.

### ease

The curve (or spring) driving the animation.

### is_relative

When `true`, [member to_value] is added to the resolved start value
instead of replacing it — e.g. move 40 pixels right from wherever the
target actually is, instead of moving to x = 40. Used by `move_by()`,
`scale_by()`, `rotate_by()`, and the generic [method relative] modifier
(`tech-spec.md` §Target-bound authoring contract). Named is_relative
rather than relative — that name is the [method relative] chain method
below, and GDScript cannot declare a method with the same name as a
property (see [method with_duration]).

### pivot

Anchor position a scale or rotation motion transforms around, restored
from Anima v1. Ignored on any other property, or a target that supports
neither `Control`'s native pivot nor an `offset`+`texture` pair
(`tech-spec.md` §Motion pivot control).

## Methods

### estimate_duration

`FIXED` for every ease except [constant AnimaEase.Kind.SPRING], which
reports `ESTIMATED` (a settle-time estimate derived from its parameters).

### create_runtime

Builds the runtime instance that animates [member target_property]. See
[method AnimaMotion.create_runtime] for [param context].

### validate

Requires [member target_property].

### with_duration

Chainable setters for the Motion builder API. Named with_duration/with_ease
rather than duration/ease — those names are already the field names above,
and GDScript cannot declare a method with the same name as a property.

### with_ease

See [method with_duration].

### with_delay

See [method with_duration]. Named with_delay rather than delay — that name
is [member AnimaMotion.delay] above, inherited from the base resource.

### from

Sets an explicit starting value instead of reading the target's current
value when playback starts. See [member from_value].

### from_current

Clears an explicit start value, restoring the default of reading the
target's current value when playback starts. Mainly useful for
readability when a chain wants to say so explicitly.

### relative

Marks [member to_value] as a delta added to the resolved start value
instead of an absolute destination. See [member is_relative].

### with_pivot

See [method with_duration]. Sets [member pivot] directly — that name is
the field above, and GDScript cannot declare a method with the same name.
