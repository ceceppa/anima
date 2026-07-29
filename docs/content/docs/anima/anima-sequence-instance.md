---
weight: 110
title: "AnimaSequenceInstance"
description: "The internal runtime behaviour behind AnimaSequence."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaSequenceInstance

`AnimaSequenceInstance` is the internal class that steps through an [`AnimaSequence`](./anima-sequence.md)'s children one at a time, frame by frame. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaSequenceInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaSequence`](./anima-sequence.md), Anima creates one of these behind the scenes to track which child is currently active, advance it, and move on to the next enabled child once it finishes.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaSequenceInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances the currently active child by one frame's worth of time. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances whichever child is currently active. Once that child finishes, moves on to the next enabled child. Returns `true` once every enabled child has finished.

## Related API

- [`AnimaSequence`](./anima-sequence.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_sequence_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_sequence_instance.gd)
