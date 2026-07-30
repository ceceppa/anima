---
weight: 140
title: "AnimaRace"
description: "Runs a list of motions together; finishes as soon as the fastest one does."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaRace

`AnimaRace` starts every motion in its list at the same time and finishes the moment the fastest one does — the rest simply stop being advanced.

```gdscript
class_name AnimaRace
extends AnimaMotion
```

## Overview

Use `AnimaRace` when you want "whichever finishes first wins" behaviour — for example, two competing visual effects where only the winner's final state should matter.

Unlike [`AnimaParallel`](./anima-parallel.md), which lets you pick a specific child to decide completion, `AnimaRace` always completes on whichever enabled child happens to be fastest.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaRace
```

## Quick example

This animates two properties at different speeds — the race finishes as soon as the faster one (the fade) completes:

```gdscript
var fade := AnimaPropertyMotion.new()
fade.target_property = NodePath("modulate:a")
fade.to_value = 1.0
fade.duration = 0.2

var slide := AnimaPropertyMotion.new()
slide.target_property = NodePath("position:x")
slide.to_value = 100.0
slide.duration = 0.8

var race := AnimaRace.new()
race.children = [fade, slide]

Anima.play(race, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`children`](#children) | `Array[AnimaMotion]` | `[]` | The motions racing against each other. |
| [`cancel_remaining`](#cancel_remaining) | `bool` | `true` | Reserved for future use — has no defined effect when set to `false`. |

---

### `children`

```gdscript
var children: Array[AnimaMotion] = []
```

The list of motions racing each other. Each entry can be any [`AnimaMotion`](./anima-motion.md).

---

### `cancel_remaining`

```gdscript
var cancel_remaining: bool = true
```

Exists for future extensibility. Setting this to `false` currently has no defined effect — the losing children are always simply left un-advanced once the race finishes.

## Limitations

- Once the race finishes, the remaining (slower) children just stop being advanced — they are not explicitly cancelled or completed early, so their target properties are left wherever they happened to reach.

## Related API

- [`AnimaParallel`](./anima-parallel.md)
- [`AnimaConditional`](./anima-conditional.md)
- [`Anima`](./anima.md)

## Source

- [`anima_race.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_race.gd)
