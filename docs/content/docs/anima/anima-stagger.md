---
weight: 160
title: "AnimaStagger"
description: "Plays the same motion across several targets, started a short interval apart."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaStagger

`AnimaStagger` plays one copy of the same motion against every node in a list, starting each one a short interval after the last — the classic "items appearing one after another" effect.

```gdscript
class_name AnimaStagger
extends AnimaMotion
```

## Overview

Use `AnimaStagger` for effects like a row of buttons fading in one at a time, or a list of items sliding in with a ripple effect. You provide one `template` motion and a list of target nodes — Anima builds one instance of `template` per target and starts them `interval` seconds apart, in whichever `order` you choose.

Unlike every other motion type, `AnimaStagger` doesn't animate the single node passed to [`Anima.play()`](./anima.md) — it drives its own `targets` list instead. You can pass `null` as the target when playing a stagger.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaStagger
```

## Quick example

This fades in three labels, 0.1 seconds apart:

```gdscript
var fade_in := AnimaPropertyMotion.new()
fade_in.target_property = NodePath("modulate:a")
fade_in.from_value = 0.0
fade_in.to_value = 1.0
fade_in.duration = 0.3

var stagger := AnimaStagger.new()
stagger.template = fade_in
stagger.targets = [$Label1, $Label2, $Label3]
stagger.interval = 0.1

Anima.play(stagger, null)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Label1`, `$Label2`, and `$Label3` refer to nodes already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`template`](#template) | [`AnimaMotion`](./anima-motion.md) | `null` | The motion played against every entry in `targets`. |
| [`targets`](#targets) | `Array` | `[]` | The nodes `template` plays against, one instance each. |
| [`interval`](#interval) | `float` | `0.05` | Seconds between one target starting and the next. |
| [`order`](#order) | `Order` | `FORWARD` | The order `targets` start in. |
| [`custom_order`](#custom_order) | `Array[int]` | `[]` | Explicit start-order indices, used only when `order` is `CUSTOM`. |

---

### `template`

```gdscript
var template: AnimaMotion = null
```

The motion played against every entry in `targets` — a fresh instance is created for each one. Required — [`validate()`](./anima-motion.md#validate) reports an error if this is left unset.

---

### `targets`

```gdscript
var targets: Array = []
```

The list of nodes `template` plays against, one at a time in the order [`resolve_order()`](#resolve_order) works out.

---

### `interval`

```gdscript
var interval: float = 0.05
```

How many seconds after one target starts before the next one starts.

---

### `order`

```gdscript
var order: Order = Order.FORWARD
```

Controls which target starts first, second, and so on. See [Enumerations](#enumerations) below.

---

### `custom_order`

```gdscript
var custom_order: Array[int] = []
```

Only used when `order` is `CUSTOM`. Must contain exactly one entry per item in `targets` — each value is an index into `targets`, in the order they should start.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`resolve_order()`](#resolve_order) | `Array[int]` | Returns the target indices in the order they should start. |

---

### `resolve_order()`

```gdscript
func resolve_order() -> Array[int]
```

Works out the actual start order for `targets`, based on `order`. You don't normally need to call this yourself — it's used internally when the stagger plays — but it's useful if you want to preview the order without playing anything.

## Enumerations

### `Order`

```gdscript
enum Order {
    FORWARD,
    REVERSE,
    FROM_CENTER,
    FROM_EDGES,
    CUSTOM,
    RANDOM,
}
```

| Value | Description |
|---|---|
| `FORWARD` | Targets start in the order they appear in `targets`. This is the default. |
| `REVERSE` | Targets start in the opposite order. |
| `FROM_CENTER` | The middle target (or targets) start first, then the effect spreads outward. |
| `FROM_EDGES` | The first and last targets start first, then the effect closes inward. |
| `CUSTOM` | Uses `custom_order` to decide the exact start order. |
| `RANDOM` | Targets start in a random order, re-shuffled every time the stagger plays. |

## Limitations

- `targets` is a plain `Array`, not a typed `Array[Node]` — this is a deliberate workaround for a Godot 4.6 limitation with typed arrays on Resource scripts.

## Related API

- [`AnimaParallel`](./anima-parallel.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`Anima`](./anima.md)

## Source

- [`anima_stagger.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_stagger.gd)
