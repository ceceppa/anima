---
weight: 180
title: "Motion"
description: "A fluent, chainable shortcut for building Anima's motion resources."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# Motion

`Motion` is a set of static factory functions that build the same motion resources you'd otherwise construct by hand — just with less boilerplate.

```gdscript
class_name Motion
extends RefCounted
```

## Overview

Building a motion directly means creating the resource, then setting each property on its own line:

```gdscript
var motion := AnimaSequence.new()
motion.children = [fade, slide]
```

`Motion` collapses that into a single call:

```gdscript
var motion := Motion.sequence([fade, slide])
```

Every function on `Motion` returns exactly the same kind of resource direct construction would — there's no new runtime behavior here, just a shorter way to write it. `Motion` is intentionally left unprefixed (rather than `AnimaMotionBuilder` or similar) since it reads better at the call site: `Motion.sequence(...)`, `Motion.stagger(...)`.

## Inheritance

```text
Object
└── RefCounted
    └── Motion
```

## Quick example

```gdscript
var fade := Motion.to(NodePath("modulate:a"), 1.0)
var slide := Motion.to(NodePath("position:x"), 100.0)

var intro := Motion.sequence([fade, slide])

Anima.play(intro, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`sequence()`](#sequence) | [`AnimaSequence`](./anima-sequence.md) | Builds a sequence playing `children` one after another. |
| [`parallel()`](#parallel) | [`AnimaParallel`](./anima-parallel.md) | Builds a parallel group playing `children` together. |
| [`stagger()`](#stagger) | [`AnimaStagger`](./anima-stagger.md) | Builds a stagger playing `template` against each of `targets`. |
| [`repeat()`](#repeat) | [`AnimaRepeat`](./anima-repeat.md) | Builds a repeat playing `child` `count` times. |
| [`race()`](#race) | [`AnimaRace`](./anima-race.md) | Builds a race that completes as soon as the fastest of `children` finishes. |
| [`conditional()`](#conditional) | [`AnimaConditional`](./anima-conditional.md) | Builds a conditional that plays one of two branches depending on `condition`. |
| [`to()`](#to) | [`AnimaPropertyMotion`](./anima-property-motion.md) | Builds a property motion animating `target_property` to `to_value`. |

---

### `sequence()`

```gdscript
static func sequence(children: Array[AnimaMotion]) -> AnimaSequence
```

Builds an [`AnimaSequence`](./anima-sequence.md) playing `children` one after another.

---

### `parallel()`

```gdscript
static func parallel(children: Array[AnimaMotion]) -> AnimaParallel
```

Builds an [`AnimaParallel`](./anima-parallel.md) playing `children` together.

---

### `stagger()`

```gdscript
static func stagger(targets: Array[Node], template: AnimaMotion, interval: float) -> AnimaStagger
```

Builds an [`AnimaStagger`](./anima-stagger.md) playing `template` against each of `targets`, `interval` seconds apart.

---

### `repeat()`

```gdscript
static func repeat(child: AnimaMotion, count: int) -> AnimaRepeat
```

Builds an [`AnimaRepeat`](./anima-repeat.md) playing `child` `count` times.

---

### `race()`

```gdscript
static func race(children: Array[AnimaMotion]) -> AnimaRace
```

Builds an [`AnimaRace`](./anima-race.md) that completes as soon as the fastest of `children` finishes.

---

### `conditional()`

```gdscript
static func conditional(condition: Callable, when_true: AnimaMotion, when_false: AnimaMotion) -> AnimaConditional
```

Builds an [`AnimaConditional`](./anima-conditional.md) that plays `when_true` or `when_false` depending on `condition`.

---

### `to()`

```gdscript
static func to(target_property: NodePath, to_value: Variant) -> AnimaPropertyMotion
```

Builds an [`AnimaPropertyMotion`](./anima-property-motion.md) animating `target_property` to `to_value`.

## Related API

- [`AnimaMotion`](./anima-motion.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`Anima`](./anima.md)

## Source

- [`anima_motion_builder.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_motion_builder.gd)
