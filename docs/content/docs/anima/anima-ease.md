---
weight: 30
title: "AnimaEase"
description: "A curve resource controlling the pacing of a property animation."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaEase

`AnimaEase` describes how a property animates over time — at a constant speed, starting slow and speeding up, or one of a few other basic curve shapes. Every [`AnimaPropertyMotion`](./anima-property-motion.md) uses one.

```gdscript
class_name AnimaEase
extends Resource
```

## Overview

An easing curve is what makes motion feel natural instead of mechanical. Without one, a property changes at a perfectly constant rate for its whole duration — with one, it can start slowly and accelerate, or the reverse.

You create an `AnimaEase`, pick a `kind`, and assign it to a motion's `ease` property. If you don't assign one, `AnimaPropertyMotion` uses a plain linear curve by default.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaEase
```

## Quick example

```gdscript
var ease := AnimaEase.new()
ease.kind = AnimaEase.Kind.SINE

var motion := AnimaPropertyMotion.new()
motion.target_property = NodePath("position:x")
motion.to_value = 200.0
motion.duration = 0.5
motion.ease = ease

Anima.play(motion, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`kind`](#kind) | `Kind` | `LINEAR` | Which curve shape to use. |
| [`exponent`](#exponent) | `float` | `2.0` | Only used when `kind` is `POLYNOMIAL`. |

---

### `kind`

```gdscript
var kind: Kind = Kind.LINEAR
```

Selects which curve shape this easing uses. See [Enumerations](#enumerations) below for every available value.

---

### `exponent`

```gdscript
var exponent: float = 2.0
```

Only has an effect when `kind` is `POLYNOMIAL`. A value of `2.0` gives a gentle acceleration; higher values accelerate more sharply.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`evaluate()`](#evaluate) | `float` | Given a progress from `0.0` to `1.0`, returns the eased progress. |

---

### `evaluate()`

```gdscript
func evaluate(t: float) -> float
```

Takes a plain linear progress value between `0.0` (start) and `1.0` (end) and returns the eased value for that same moment. You don't normally call this yourself — [`AnimaPropertyMotion`](./anima-property-motion.md) calls it internally every frame — but it's useful if you want to preview or graph a curve.

## Enumerations

### `Kind`

```gdscript
enum Kind {
    LINEAR,
    POLYNOMIAL,
    SINE,
    EXPONENTIAL,
    CIRCULAR,
}
```

| Value | Description |
|---|---|
| `LINEAR` | Constant speed from start to end. |
| `POLYNOMIAL` | Accelerates according to `exponent`. |
| `SINE` | A gentle, sine-wave-shaped acceleration. |
| `EXPONENTIAL` | Starts very slowly, then accelerates sharply near the end. |
| `CIRCULAR` | A curve based on a quarter-circle arc. |

## Limitations

- This is a basic curve set. Spring, decay, cubic Bézier, custom curve resources, and custom sampled curves are not available yet.

## Related API

- [`AnimaPropertyMotion`](./anima-property-motion.md)

## Source

- [`anima_ease.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_ease.gd)
