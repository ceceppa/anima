---
weight: 150
title: "AnimaRepeat"
description: "Replays a motion a set number of times, with an optional delay between repeats."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaRepeat

`AnimaRepeat` plays a single motion over and over, a set number of times, optionally waiting a moment between each repeat.

```gdscript
class_name AnimaRepeat
extends AnimaMotion
```

## Overview

Use `AnimaRepeat` for anything that should visibly happen more than once — a pulsing highlight, a bouncing icon, a blinking warning. Set `alternate` to `true` to have it ping-pong back and forth instead of always replaying the same direction.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaRepeat
```

## Quick example

This pulses a node's scale up and back down, three times, with a short pause between each pulse:

```gdscript
var pulse := AnimaPropertyMotion.new()
pulse.target_property = NodePath("scale")
pulse.from_value = Vector2.ONE
pulse.to_value = Vector2(1.2, 1.2)
pulse.duration = 0.2

var repeat := AnimaRepeat.new()
repeat.child = pulse
repeat.count = 3
repeat.delay_between = 0.1
repeat.alternate = true

Anima.play(repeat, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`child`](#child) | [`AnimaMotion`](./anima-motion.md) | `null` | The motion to repeat. |
| [`count`](#count) | `int` | `1` | How many times `child` plays. |
| [`delay_between`](#delay_between) | `float` | `0.0` | Seconds to wait between one repeat ending and the next starting. |
| [`alternate`](#alternate) | `bool` | `false` | Whether odd repeats reverse `child` instead of replaying it identically. |

---

### `child`

```gdscript
var child: AnimaMotion = null
```

The motion to repeat. Required — [`validate()`](./anima-motion.md#validate) reports an error if this is left unset.

---

### `count`

```gdscript
var count: int = 1
```

How many times `child` plays in total. `count` is always a fixed, whole number — there's no "repeat forever" option yet.

---

### `delay_between`

```gdscript
var delay_between: float = 0.0
```

How long, in seconds, `AnimaRepeat` waits after one repeat finishes before starting the next one.

---

### `alternate`

```gdscript
var alternate: bool = false
```

When `true`, every other repeat (the 2nd, 4th, and so on) reverses `child` instead of replaying it the same way — this only has a defined effect when `child` is an [`AnimaPropertyMotion`](./anima-property-motion.md), in which case its `from_value` and `to_value` are swapped for that repeat. Reversing a composite `child` (like an [`AnimaSequence`](./anima-sequence.md)) isn't defined yet.

## Limitations

- `alternate` only reverses a single [`AnimaPropertyMotion`](./anima-property-motion.md) child. A composite child (Sequence, Parallel, and similar) always replays forward on every repeat.
- `count` must be a fixed whole number decided up front — there's no indefinite/infinite repeat yet.

## Related API

- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`Anima`](./anima.md)

## Source

- [`anima_repeat.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_repeat.gd)
