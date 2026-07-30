---
weight: 170
title: "AnimaDuration"
description: "How long a motion is expected to take, and how certain that estimate is."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaDuration

`AnimaDuration` is what [`estimate_duration()`](./anima-motion.md#estimate_duration) returns — not just a number of seconds, but also how certain that number is.

```gdscript
class_name AnimaDuration
extends RefCounted
```

## Overview

Some motions know exactly how long they'll take before they even start — an [`AnimaPropertyMotion`](./anima-property-motion.md) with a plain `duration` set, for example. Others can only guess (a spring-eased motion, which settles on its own schedule), and others genuinely don't know until they actually run (an [`AnimaConditional`](./anima-conditional.md), which doesn't pick a branch until playback starts). `AnimaDuration`'s `kind` tells you which situation you're in, so code that reads a duration doesn't mistake a rough guess for an exact number.

You don't normally construct an `AnimaDuration` yourself — you get one back from calling `estimate_duration()` on any [`AnimaMotion`](./anima-motion.md). The static helper methods below (`fixed()`, `estimated()`, `dynamic()`) are what motion types use internally to build the ones they return.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaDuration
```

## Quick example

```gdscript
var motion := AnimaPropertyMotion.new()
motion.target_property = NodePath("position:x")
motion.to_value = 100.0
motion.duration = 0.5

var duration := motion.estimate_duration()
if duration.kind == AnimaDuration.Kind.FIXED:
    print("This motion takes exactly %s seconds" % duration.seconds)
```

> This example assumes Anima is installed and enabled in the current Godot project.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`kind`](#kind) | `Kind` | `FIXED` | How certain this duration is. |
| [`seconds`](#seconds) | `float` | `0.0` | The duration in seconds — meaningful only for `FIXED` and `ESTIMATED`. |

---

### `kind`

```gdscript
var kind: Kind = Kind.FIXED
```

How certain this duration is. See [Enumerations](#enumerations) below.

---

### `seconds`

```gdscript
var seconds: float = 0.0
```

The duration in seconds. Only meaningful when `kind` is `FIXED` or `ESTIMATED` — for `DYNAMIC` and `INFINITE`, this is always `0.0` and should be ignored.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`fixed()`](#fixed) | `AnimaDuration` | Builds a `FIXED` duration. |
| [`estimated()`](#estimated) | `AnimaDuration` | Builds an `ESTIMATED` duration. |
| [`dynamic()`](#dynamic) | `AnimaDuration` | Builds a `DYNAMIC` duration (no known length). |
| [`worst_kind()`](#worst_kind) | `Kind` | Returns the least certain kind among a list of durations. |

---

### `fixed()`

```gdscript
static func fixed(p_seconds: float) -> AnimaDuration
```

Builds a duration with `kind = FIXED` and the given number of seconds — used for a motion whose length is known exactly ahead of time.

---

### `estimated()`

```gdscript
static func estimated(p_seconds: float) -> AnimaDuration
```

Builds a duration with `kind = ESTIMATED` and the given number of seconds — used for a motion whose length is a rough guess rather than an exact number. A spring-eased [`AnimaPropertyMotion`](./anima-property-motion.md) reports one of these, since a spring settles on its own schedule rather than a fixed timer.

---

### `dynamic()`

```gdscript
static func dynamic() -> AnimaDuration
```

Builds a duration with `kind = DYNAMIC` and `seconds = 0.0` — used for a motion whose length genuinely isn't known yet, such as an [`AnimaConditional`](./anima-conditional.md) that hasn't picked a branch.

---

### `worst_kind()`

```gdscript
static func worst_kind(durations: Array[AnimaDuration]) -> Kind
```

Given a list of durations (typically a composite motion's children), returns whichever `kind` is least certain among them. Composite motions like [`AnimaSequence`](./anima-sequence.md) and [`AnimaParallel`](./anima-parallel.md) use this to decide their own reported `kind` — if even one child is `DYNAMIC`, the whole group reports `DYNAMIC` too, since its numeric length can't be pinned down either.

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `durations` | `Array[AnimaDuration]` | The durations to compare. |

## Enumerations

### `Kind`

```gdscript
enum Kind {
    FIXED,
    ESTIMATED,
    DYNAMIC,
    INFINITE,
}
```

| Value | Description |
|---|---|
| `FIXED` | The exact length is known ahead of time. |
| `ESTIMATED` | The length is a rough guess, not an exact number — for example, a spring-eased motion's settle time. |
| `DYNAMIC` | The length genuinely isn't known yet — it depends on something resolved only at runtime. |
| `INFINITE` | The motion has no defined end. Reserved for future use — no motion type reports this yet. |

Values are listed worst-to-best in certainty, which is what [`worst_kind()`](#worst_kind) compares against.

## Related API

- [`AnimaMotion`](./anima-motion.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`AnimaConditional`](./anima-conditional.md)

## Source

- [`anima_duration.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_duration.gd)
