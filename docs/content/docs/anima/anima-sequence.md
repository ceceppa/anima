---
weight: 40
title: "AnimaSequence"
description: "Runs a list of motions one after another."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaSequence

`AnimaSequence` runs a list of motions strictly one after another — the second one doesn't start until the first has finished, and so on.

```gdscript
class_name AnimaSequence
extends AnimaMotion
```

## Overview

Use `AnimaSequence` whenever you want to say "do this, then that" without calculating start times by hand. Anima works out the timing for you: if you change how long one child takes, everything after it automatically shifts.

A child with [`enabled`](./anima-motion.md#enabled) set to `false` is skipped entirely, as if it weren't in the list.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaSequence
```

## Quick example

This moves a panel in, then fades a label in after the panel has finished moving:

```gdscript
var move_panel := AnimaPropertyMotion.new()
move_panel.target_property = NodePath("position:y")
move_panel.to_value = 0.0
move_panel.duration = 0.4

var fade_label := AnimaPropertyMotion.new()
fade_label.target_property = NodePath("modulate:a")
fade_label.to_value = 1.0
fade_label.duration = 0.3

var sequence := AnimaSequence.new()
sequence.children = [move_panel, fade_label]

Anima.play(sequence, $Panel)
```

> This example plays both motions on the same node for simplicity. In practice, each child motion can target any node — see [`AnimaParallel`](./anima-parallel.md) for playing motions on different nodes together.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`children`](#children) | `Array[AnimaMotion]` | `[]` | The motions to run one after another, in order. |

---

### `children`

```gdscript
var children: Array[AnimaMotion] = []
```

The list of motions this sequence runs in order. Each entry can be any [`AnimaMotion`](./anima-motion.md) — a plain [`AnimaPropertyMotion`](./anima-property-motion.md), or even another `AnimaSequence` or [`AnimaParallel`](./anima-parallel.md) nested inside.

## Related API

- [`AnimaParallel`](./anima-parallel.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`Anima`](./anima.md)

## Source

- [`anima_sequence.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_sequence.gd)
