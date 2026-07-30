---
weight: 10
title: "AnimaMotion"
description: "The base contract every Anima motion resource extends."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaMotion

`AnimaMotion` is the base type every animation description in Anima extends. You will not create an `AnimaMotion` directly — instead you create one of its subtypes, like [`AnimaPropertyMotion`](./anima-property-motion.md), [`AnimaSequence`](./anima-sequence.md), or [`AnimaParallel`](./anima-parallel.md).

```gdscript
class_name AnimaMotion
extends Resource
```

## Overview

A **[`Resource`](https://docs.godotengine.org/en/stable/classes/class_resource.html)** is Godot's built-in type for data that can be created, configured, and saved to disk without being part of a running scene. `AnimaMotion` is a `Resource`, which is why every motion in Anima is something you build and configure in code (or save as a file), rather than a node you add to your scene tree.

Every motion type in Anima — whether it animates a single property or composes several motions together — extends `AnimaMotion` and shares the same fields (`enabled`, `delay`, `speed`, and others) and the same three-method contract (`estimate_duration()`, `create_runtime()`, `validate()`). This is what lets [`Anima.play()`](./anima.md) treat any motion the same way, no matter which specific subtype it is.

`estimate_duration()` doesn't just return a number of seconds — it returns an [`AnimaDuration`](./anima-duration.md), which also says how certain that number is. Most motions report an exact, `FIXED` length; a spring-eased [`AnimaPropertyMotion`](./anima-property-motion.md) reports `ESTIMATED` instead, since a spring settles on its own schedule rather than a fixed timer.

You never construct a plain `AnimaMotion` yourself — you always work with one of its subtypes.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
```

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`display_name`](#display_name) | `String` | `""` | An optional human-readable name for this motion. |
| [`enabled`](#enabled) | `bool` | `true` | Whether this motion runs at all. |
| [`delay`](#delay) | `float` | `0.0` | Reserved for a future relative start-offset. Not used by any Phase 1 motion type yet. |
| [`speed`](#speed) | `float` | `1.0` | A multiplier applied to how fast this motion's own time passes. |
| [`tags`](#tags) | `Array[String]` | `[]` | Optional categorisation metadata. Nothing in Anima reads or filters on this yet. |
| [`metadata`](#metadata) | `Dictionary` | `{}` | A free-form place to attach your own data to a motion. Anima itself never reads this. |

---

### `display_name`

```gdscript
var display_name: String = ""
```

A name you can give a motion to make it easier to find in code, in the Inspector, or (for composite motions like [`AnimaParallel`](./anima-parallel.md)) to select as the child that decides when a group finishes.

---

### `enabled`

```gdscript
var enabled: bool = true
```

When `false`, a composite motion (like [`AnimaSequence`](./anima-sequence.md) or [`AnimaParallel`](./anima-parallel.md)) skips this motion entirely, as if it weren't in the list of children at all.

---

### `delay`

```gdscript
var delay: float = 0.0
```

This field exists on every motion, but no motion type in the current version reads it yet. It's reserved for a future "wait this long before starting" behaviour once relationship timing (like starting one motion partway through another) is added.

---

### `speed`

```gdscript
var speed: float = 1.0
```

Scales how quickly this motion's own internal clock advances. A value of `2.0` makes the motion run in half the time; `0.5` makes it take twice as long.

---

### `tags`

```gdscript
var tags: Array[String] = []
```

A list of your own labels for this motion. Nothing in Anima currently reads or filters by tag — it's here for your own organisation, and for a future preset browser.

---

### `metadata`

```gdscript
var metadata: Dictionary = {}
```

An empty dictionary you can fill with anything you like. Anima never reads or writes to this itself.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`estimate_duration()`](#estimate_duration) | [`AnimaDuration`](./anima-duration.md) | Returns how long this motion is expected to take, and how certain that is. |
| [`create_runtime()`](#create_runtime) | `Variant` | Creates the internal object that actually runs this motion. |
| [`validate()`](#validate) | `Array[String]` | Checks the motion is configured correctly and returns a list of problems, if any. |

---

### `estimate_duration()`

```gdscript
func estimate_duration() -> AnimaDuration
```

Every subtype of `AnimaMotion` implements this to report how long it will take to finish, as an [`AnimaDuration`](./anima-duration.md) rather than a plain number of seconds — so callers can tell an exact length apart from a rough guess. A [`AnimaSequence`](./anima-sequence.md) sums its children's durations; a [`AnimaParallel`](./anima-parallel.md) uses its longest child (by default).

You do not need to call this yourself — [`Anima.play()`](./anima.md) and the composite motion types call it internally.

---

### `create_runtime()`

```gdscript
func create_runtime() -> Variant
```

Every subtype implements this to produce the internal object that actually advances the motion frame by frame. This is called automatically when you call [`Anima.play()`](./anima.md) — you never call it yourself.

---

### `validate()`

```gdscript
func validate() -> Array[String]
```

Returns an empty array if the motion is configured correctly, or a list of human-readable problem descriptions if something is missing or invalid — for example, a [`AnimaPropertyMotion`](./anima-property-motion.md) with no target property set.

## Related API

- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaParallel`](./anima-parallel.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`AnimaDuration`](./anima-duration.md)
- [`Anima`](./anima.md)

## Source

- [`anima_motion.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_motion.gd)
