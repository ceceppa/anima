---
weight: 120
title: "AnimaParallelInstance"
description: "The internal runtime behaviour behind AnimaParallel."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaParallelInstance

`AnimaParallelInstance` is the internal class that advances every child of an [`AnimaParallel`](./anima-parallel.md) at the same time, frame by frame, and decides when the group as a whole has finished. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaParallelInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaParallel`](./anima-parallel.md), Anima creates one of these behind the scenes to advance every enabled child in step, track which ones have finished, and apply the group's [`completion_policy`](./anima-parallel.md#completion_policy) to decide when the whole group is done.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaParallelInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances every not-yet-finished child by one frame's worth of time. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances every child that hasn't finished yet. Whether this returns `true` depends on the group's [`completion_policy`](./anima-parallel.md#completion_policy): with the default `ALL_CHILDREN`, it returns `true` only once every child has finished; with `FIRST_CHILD` or `NAMED_CHILD`, it returns `true` as soon as the designated child finishes.

## Related API

- [`AnimaParallel`](./anima-parallel.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_parallel_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_parallel_instance.gd)
