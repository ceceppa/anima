---
weight: 90
title: "AnimaMotionInstance"
description: "The internal base class that advances a playing motion, frame by frame."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaMotionInstance

`AnimaMotionInstance` is the internal base class behind every motion's runtime behaviour. It is created automatically by [`AnimaMotion.create_runtime()`](./anima-motion.md#create_runtime) and is not something you construct directly.

```gdscript
class_name AnimaMotionInstance
extends RefCounted
```

## Overview

Every [`AnimaMotion`](./anima-motion.md) subtype (like [`AnimaPropertyMotion`](./anima-property-motion.md)) has a matching `AnimaMotionInstance` subtype that knows how to actually advance that specific kind of motion, frame by frame. [`AnimaPlayback`](./anima-playback.md) calls `advance()` on one of these every frame — you never call it, or create one, yourself.

This page exists mainly so you can understand what `create_runtime()` returns if you go looking for it in the source.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances the motion by one frame's worth of time. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances the motion by `delta` seconds against `target`, applying whatever change that frame requires. Returns `true` once the motion has finished, `false` otherwise. Every subtype overrides this with its own specific behaviour.

## Related API

- [`AnimaMotion`](./anima-motion.md)
- [`AnimaPlayback`](./anima-playback.md)
- [`AnimaPropertyMotionInstance`](./anima-property-motion-instance.md)
- [`AnimaSequenceInstance`](./anima-sequence-instance.md)
- [`AnimaParallelInstance`](./anima-parallel-instance.md)

## Source

- [`anima_motion_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_motion_instance.gd)
