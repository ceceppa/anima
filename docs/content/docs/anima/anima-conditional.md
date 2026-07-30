---
weight: 130
title: "AnimaConditional"
description: "Plays one of two motions, chosen by a condition you provide."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaConditional

`AnimaConditional` picks between two motions — `when_true` or `when_false` — based on a condition you give it, and plays only the one it picked.

```gdscript
class_name AnimaConditional
extends AnimaMotion
```

## Overview

Use `AnimaConditional` whenever which animation should play depends on something in your game's state — for example, playing a "success" motion or a "failure" motion depending on the outcome of an action.

The condition is a **[`Callable`](https://docs.godotengine.org/en/stable/classes/class_callable.html)** — a function reference you can pass around like a value — that takes no arguments and returns `true` or `false`. By default, `AnimaConditional` doesn't call your condition until the motion actually starts playing (`resolution_timing = RUNTIME`), and it's only ever called once per play — it never re-checks partway through.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaConditional
```

## Quick example

This plays a green flash if a check passes, or a red shake if it doesn't:

```gdscript
var on_success := AnimaPropertyMotion.new()
on_success.target_property = NodePath("modulate")
on_success.to_value = Color.GREEN
on_success.duration = 0.3

var on_failure := AnimaPropertyMotion.new()
on_failure.target_property = NodePath("position:x")
on_failure.to_value = 20.0
on_failure.duration = 0.1

var conditional := AnimaConditional.new()
conditional.condition = func() -> bool: return player_won
conditional.when_true = on_success
conditional.when_false = on_failure

Anima.play(conditional, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene, and `player_won` is a variable available where this code runs.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`when_true`](#when_true) | [`AnimaMotion`](./anima-motion.md) | `null` | Played when `condition` returns `true`. |
| [`when_false`](#when_false) | [`AnimaMotion`](./anima-motion.md) | `null` | Played when `condition` returns `false`. |
| [`condition`](#condition) | `Callable` | *(empty)* | A zero-argument function returning `bool`. |
| [`resolution_timing`](#resolution_timing) | `ResolutionTiming` | `RUNTIME` | When `condition` is evaluated. |

---

### `when_true`

```gdscript
var when_true: AnimaMotion = null
```

The motion played when `condition` returns `true`. Required — [`validate()`](./anima-motion.md#validate) reports an error if this is left unset.

---

### `when_false`

```gdscript
var when_false: AnimaMotion = null
```

The motion played when `condition` returns `false`. Required — [`validate()`](./anima-motion.md#validate) reports an error if this is left unset.

---

### `condition`

```gdscript
var condition: Callable = Callable()
```

A function taking no arguments and returning a `bool`, used to pick between `when_true` and `when_false`. Required — [`validate()`](./anima-motion.md#validate) reports an error if this isn't set to a valid `Callable`.

---

### `resolution_timing`

```gdscript
var resolution_timing: ResolutionTiming = ResolutionTiming.RUNTIME
```

Controls when `condition` gets called. See [Enumerations](#enumerations) below.

## Enumerations

### `ResolutionTiming`

```gdscript
enum ResolutionTiming {
    COMPILE_TIME,
    RUNTIME,
}
```

| Value | Description |
|---|---|
| `RUNTIME` | The default. `condition` isn't evaluated when you call [`estimate_duration()`](./anima-motion.md#estimate_duration) — only once playback actually starts. The reported duration kind is `DYNAMIC` until then. |
| `COMPILE_TIME` | `condition` is evaluated immediately when [`estimate_duration()`](./anima-motion.md#estimate_duration) is called, and the reported duration is whichever branch's own duration turns out to be. |

## Limitations

- `condition` is evaluated at most once per play — it never re-checks partway through, even if whatever it depends on changes while the motion is running.

## Related API

- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaRace`](./anima-race.md)
- [`Anima`](./anima.md)

## Source

- [`anima_conditional.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_conditional.gd)
