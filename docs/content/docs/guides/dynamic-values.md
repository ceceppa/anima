---
title: "Dynamic Value"
description: "Resolving a value against live playback state instead of a fixed literal"
---

Sometimes the value you want to animate to (or from) isn't known until the
animation actually starts — another node's current size, the target's own
current position, or a value combining more than one live property.
`AnimaValue` resolves against that live state instead of holding a fixed
literal, and can be used almost anywhere a plain value is accepted:
`AnimaPropertyMotion.from_value`/`to_value`, and a keyframe stop's `value`
(see [Keyframes](keyframes)).

```gdscript
# Fade out and slide left by the target's own width
Anima.on($Panel).move_by(
    AnimaValue.target(^"size:x").negative(),
    0.3
)
```

## Where a dynamic value can read from

- `AnimaValue.target(property)` — the animated target's own property.
- `AnimaValue.node(path, property)` — another node's property, found by
  path relative to the resolving context's root.
- `AnimaValue.root(property)` — the context's own root directly (the
  animated target for a plain motion; the group's own container for a
  group/grid item).
- `AnimaValue.context(key)` — arbitrary data supplied to the playback
  before it starts.
- `AnimaValue.group_index()` / `.group_count()` / `.group_normalised_index()`
  / `.grid_row()` / `.grid_column()` — a group/grid item's own position
  information.
- `AnimaValue.constant(value)` — wraps a plain literal, useful as one
  operand in a larger expression.

## Combining values

Every arithmetic method returns a **new** `AnimaValue` — it never mutates
the one you called it on — so the same base value can be reused safely in
more than one expression:

```gdscript
var half_width := AnimaValue.target(^"size:x").multiply(0.5)
var offset_left := half_width.negative()
var offset_right := half_width
```

`.add()`, `.subtract()`, `.multiply()`, `.divide()`, `.minimum()`,
`.maximum()` each take a literal or another `AnimaValue` as the other
operand. `.negative()`, `.absolute()`, and `.length()` (the character count
of a resolved `String` — see [Keyframes](keyframes) for its
use in `typewrite`'s duration) are unary. `.clamp(min, max)` and
`.map(in_min, in_max, out_min, out_max)` reshape a resolved range.
`.x()`/`.y()`/`.z()`/`.component(index)` pull one component out of a
resolved vector.

## Resolution timing

A dynamic value resolves exactly once, when the motion it's attached to
starts playing — never re-read mid-animation, and never resolved early at
authoring time. See the generated [AnimaValue](../../anima/anima-value)
reference for the complete operation list.
