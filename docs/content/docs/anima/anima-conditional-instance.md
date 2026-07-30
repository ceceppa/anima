---
weight: 210
title: "AnimaConditionalInstance"
description: "The internal runtime behaviour behind AnimaConditional."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaConditionalInstance

`AnimaConditionalInstance` is the internal class that selects an [`AnimaConditional`](./anima-conditional.md)'s branch once and advances only that branch. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaConditionalInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaConditional`](./anima-conditional.md), Anima creates one of these behind the scenes. It evaluates `condition` exactly once, at construction, and builds a runtime instance for whichever of `when_true` / `when_false` was selected — `condition` is never re-evaluated afterward, even if playback takes several frames.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaConditionalInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances the branch selected at construction. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances the branch selected when this instance was created. Returns `true` immediately, without advancing anything, if `condition` had no valid branch to select (both `when_true` and `when_false` resolved to `null`).

## Related API

- [`AnimaConditional`](./anima-conditional.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_conditional_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_conditional_instance.gd)
