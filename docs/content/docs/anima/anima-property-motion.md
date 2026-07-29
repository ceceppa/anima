---
weight: 20
title: "AnimaPropertyMotion"
description: "Animates a single property on a node from one value to another."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaPropertyMotion

`AnimaPropertyMotion` animates a single property on a node — its position, its colour, its scale, anything you could normally set with a line of code — smoothly changing from one value to another over time.

```gdscript
class_name AnimaPropertyMotion
extends AnimaMotion
```

## Overview

This is the simplest motion type in Anima, and the one you'll use most often. You tell it which property to animate, what value to end at, and how long it should take — Anima handles reading the starting value and updating the property every frame.

You create `AnimaPropertyMotion` instances directly, either on their own or as part of a larger [`AnimaSequence`](./anima-sequence.md) or [`AnimaParallel`](./anima-parallel.md).

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaPropertyMotion
```

## Quick example

This fades a `Sprite2D` node's transparency from whatever it currently is down to fully transparent, over half a second:

```gdscript
var motion := AnimaPropertyMotion.new()
motion.target_property = NodePath("modulate:a")
motion.to_value = 0.0
motion.duration = 0.5

Anima.play(motion, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`target_property`](#target_property) | `NodePath` | *(empty)* | Which property on the target node to animate. |
| [`from_value`](#from_value) | `Variant` | `null` | The value to start from. |
| [`to_value`](#to_value) | `Variant` | `null` | The value to end at. |
| [`duration`](#duration) | `float` | `0.0` | How many seconds the animation takes. |
| [`ease`](#ease) | [`AnimaEase`](./anima-ease.md) | linear | The easing curve applied while animating. |

---

### `target_property`

```gdscript
var target_property: NodePath = NodePath()
```

A **[`NodePath`](https://docs.godotengine.org/en/stable/classes/class_nodepath.html)** is Godot's way of pointing at a property, optionally reaching into a sub-value with a colon — for example `NodePath("position:x")` targets just the horizontal part of a node's position, and `NodePath("modulate:a")` targets just the transparency of its colour.

This must be set before the motion is played — an unset `target_property` fails [`validate()`](./anima-motion.md#validate) with an error.

---

### `from_value`

```gdscript
var from_value: Variant = null
```

The value the property animates from. Leave this as `null` (the default) to have Anima read the target's current value the moment playback starts — this is almost always what you want.

---

### `to_value`

```gdscript
var to_value: Variant = null
```

The value the property animates to. This must match the type of the property you're targeting (a `float` for `position:x`, a `Color` for `modulate`, and so on).

---

### `duration`

```gdscript
var duration: float = 0.0
```

How many seconds the animation takes to go from `from_value` to `to_value`.

---

### `ease`

```gdscript
var ease: AnimaEase = AnimaEase.new()
```

Controls the pacing of the animation — see [`AnimaEase`](./anima-ease.md). Defaults to a plain linear curve if you don't set one.

## Related API

- [`AnimaEase`](./anima-ease.md)
- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaParallel`](./anima-parallel.md)
- [`Anima`](./anima.md)

## Source

- [`anima_property_motion.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_property_motion.gd)
