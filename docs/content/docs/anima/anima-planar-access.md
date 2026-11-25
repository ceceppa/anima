---
title: "AnimaPlanarAccess"
description: "Reads and writes 2D-authored property values on a [Node3D], so a motion"
---

# AnimaPlanarAccess

## Overview

Reads and writes 2D-authored property values on a [Node3D], so a motion
written for a Control or Node2D (every catalog preset) also plays on a 3D
node. Used for an [AnimaKeyframeMotion] whose [member
AnimaKeyframeMotion.planar] is `true`; for any other motion, or any
non-[Node3D] target, [method read] and [method write] are a plain
[method Object.get_indexed] / [method Object.set_indexed].

The values land on the node's local XY plane, which faces a default
[Camera3D] looking down -Z. Distances convert at [member pixels_per_metre],
so a preset's pixel offsets and its [code]size[/code]-relative offsets
keep the same proportions they have on a Control:
[br]- [code]position[/code], [code]position:x[/code], [code]position:y[/code]:
converted to metres; the y sign flips, because 2D's y axis points down and
3D's points up.
[br]- [code]scale[/code] ([Vector2]): x and y as written; z follows x.
[br]- [code]rotation[/code] (a single angle): rotation around Z, sign flipped
for the same reason as y.
[br]- [code]modulate:a[/code]: the node's own [code]modulate[/code] when it has
one ([Label3D], [Sprite3D]); otherwise
[member GeometryInstance3D.transparency] on the node and every geometry
below it. A fully transparent geometry also stops casting shadows, which
transparency alone doesn't do; its own shadow setting comes back as soon
as it is visible again.
[br]- [code]transform:x:y[/code], [code]transform:y:x[/code] (skew): shear of
[member Node3D.basis], sign flipped.
[br]- [code]size[/code], [code]size:x[/code], [code]size:y[/code]: read-only;
the node's visual bounds in its own unscaled local space, converted to
pixels. Writing them does nothing.
[br]Anything else passes through unchanged.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### read

Returns [param path] on [param node], read as 2D when [param planar] is
`true` and [param node] is a [Node3D].

### write

Writes [param value] to [param path] on [param node], mapped from 2D when
[param planar] is `true` and [param node] is a [Node3D].

### visual_size

The XY size of every [VisualInstance3D] in [param node]'s subtree (itself
included), measured in [param node]'s own unscaled local space — the 3D
stand-in for [member Control.size]. [constant Vector2.ZERO] when the node
has no visuals or isn't in the scene tree.
