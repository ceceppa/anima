---
title: "AnimaOnMotionFactory"
description: "Returned by [method Anima.on] — builds a canonical [AnimaPropertyMotion]"
---

# AnimaOnMotionFactory

## Overview

Returned by [method Anima.on] — builds a canonical [AnimaPropertyMotion]
for a common change to [member target] through a discoverable, named
method instead of a raw property path. Every method below returns the
same kind of resource [method Motion.to] would build; chaining a second
semantic method (e.g. `.position().opacity()`) is not supported, because
the first call already returns a motion, not this factory — combine
motions explicitly with `then()`/`with()` instead
(`tech-spec.md` §Convenience method interface).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### target

The node every semantic method below animates.

## Methods

### position

Animates [member target]'s position to [param to] — a [Vector2] for a
[Control]/[Node2D] target, a [Vector3] for a [Node3D] target.

### move_by

Moves [member target] by [param delta] from wherever it actually is when
playback starts, instead of to an absolute destination. Same typing as
[method position].

### position_x

Animates just the x component of [member target]'s position.

### position_y

Animates just the y component of [member target]'s position.

### position_z

Animates just the z component of [member target]'s position. [Node3D] targets only.

### scale

Animates [member target]'s scale to [param to]. Same typing as [method position].

### scale_by

Scales [member target] by [param delta] from its actual current scale.
Same typing as [method position].

### rotation

Animates [member target]'s rotation (radians) to [param to]. [Control]/[Node2D]
targets only — a [Node3D]'s rotation is three axes, not one value; use
[method property] for 3D rotation.

### rotate_by

Rotates [member target] by [param delta] radians from its actual current
rotation. Same restriction as [method rotation].

### opacity

Fades [member target]'s opacity ([code]modulate:a[/code]) to [param to].
[CanvasItem] ([Control]/[Node2D]) targets only. A value outside `0.0..1.0`
is allowed and produces an editor warning, never a clamp or a rejection.

### fade_out

Fades [member target] out to fully transparent — sugar for [method opacity]
with [code]to = 0.0[/code]. Same target restriction as [method opacity].

### fade_in

Fades [member target] in to fully opaque — sugar for [method opacity] with
[code]to = 1.0[/code]. Same target restriction as [method opacity].

### color

Animates [member target]'s colour ([code]modulate[/code]) to [param to].
[CanvasItem] ([Control]/[Node2D]) targets only. Spelled `.color()` to
match Godot's own [Color] naming.

### size

Animates a [Control]'s size to [param to]. [Control] targets only. When
the target's size or position is actually owned by a parent [Container]
or by its own anchors, this produces an editor warning steering toward a
Layout Transition instead — it does not block the motion.

### keyframes

Builds an [AnimaKeyframeMotion] for [member target] the same way [method
Motion.keyframes] does — [param initial], if non-empty, is parsed
immediately, and the result also accepts further [method
AnimaKeyframeMotion.at] calls. Unlike every semantic method above, no
target-class validation happens here: a keyframe's tracks can name any
property, so there is no single expected value type to check against.

### property

Generic escape hatch for any other property. Delegates directly to
[method Motion.to] — the same canonical resource direct authoring would
build, with no target-class restriction of its own.

### property_by

Same as [method property], except [param delta] is added to whatever
[param path] actually holds when the motion begins, instead of replacing
it — the generic counterpart to [method move_by]/[method rotate_by]/
[method scale_by] for any other property.
