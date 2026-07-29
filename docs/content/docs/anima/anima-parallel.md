---
weight: 50
title: "AnimaParallel"
description: "Runs a list of motions all at the same time."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaParallel

`AnimaParallel` starts every motion in its list at the same time, and finishes according to a rule you choose — by default, once every child has finished.

```gdscript
class_name AnimaParallel
extends AnimaMotion
```

## Overview

Use `AnimaParallel` whenever you want several things to happen together — for example, a panel sliding in while its background fades in at the same time.

By default, an `AnimaParallel` finishes once **every** enabled child has finished (its overall duration is whichever child takes the longest). You can change this with `completion_policy` if you want the group to finish as soon as one particular child does, instead of waiting for all of them.

A child with [`enabled`](./anima-motion.md#enabled) set to `false` is skipped entirely.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaMotion
            └── AnimaParallel
```

## Quick example

This moves a panel and fades its background in at the same time:

```gdscript
var move_panel := AnimaPropertyMotion.new()
move_panel.target_property = NodePath("position:y")
move_panel.to_value = 0.0
move_panel.duration = 0.4

var fade_background := AnimaPropertyMotion.new()
fade_background.target_property = NodePath("modulate:a")
fade_background.to_value = 1.0
fade_background.duration = 0.3

var group := AnimaParallel.new()
group.children = [move_panel, fade_background]

Anima.play(group, $Panel)
```

> This example plays both motions on the same node for simplicity. Each child motion can be played against its own node too — see [`Anima.play()`](./anima.md).

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`children`](#children) | `Array[AnimaMotion]` | `[]` | The motions to run at the same time. |
| [`completion_policy`](#completion_policy) | `CompletionPolicy` | `ALL_CHILDREN` | Which rule decides when the group finishes. |
| [`completion_child_name`](#completion_child_name) | `String` | `""` | Used only when `completion_policy` is `NAMED_CHILD`. |

---

### `children`

```gdscript
var children: Array[AnimaMotion] = []
```

The list of motions this group runs at the same time. Each entry can be any [`AnimaMotion`](./anima-motion.md).

---

### `completion_policy`

```gdscript
var completion_policy: CompletionPolicy = CompletionPolicy.ALL_CHILDREN
```

Controls which child (or children) decide when the whole group is considered finished. See [Enumerations](#enumerations) below.

---

### `completion_child_name`

```gdscript
var completion_child_name: String = ""
```

Only used when `completion_policy` is `NAMED_CHILD`. Set this to match the [`display_name`](./anima-motion.md#display_name) of whichever child should decide completion.

## Enumerations

### `CompletionPolicy`

```gdscript
enum CompletionPolicy {
    ALL_CHILDREN,
    FIRST_CHILD,
    NAMED_CHILD,
}
```

| Value | Description |
|---|---|
| `ALL_CHILDREN` | The group finishes once every enabled child has finished. This is the default. |
| `FIRST_CHILD` | The group finishes as soon as the first enabled child in the list finishes, regardless of the others. |
| `NAMED_CHILD` | The group finishes as soon as the child named by `completion_child_name` finishes, regardless of the others. |

## Limitations

- With `FIRST_CHILD` or `NAMED_CHILD`, any children still running when the group finishes simply stop being advanced — they are not explicitly cancelled or completed early.

## Related API

- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`Anima`](./anima.md)

## Source

- [`anima_parallel.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_parallel.gd)
