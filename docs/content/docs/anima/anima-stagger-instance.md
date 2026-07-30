---
weight: 240
title: "AnimaStaggerInstance"
description: "The internal runtime behaviour behind AnimaStagger."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaStaggerInstance

`AnimaStaggerInstance` is the internal class that starts one [`AnimaStagger`](./anima-stagger.md) `template` instance per target, each on its own schedule, and drives all of them until every target has finished. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaStaggerInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaStagger`](./anima-stagger.md), Anima creates one of these behind the scenes. At construction, it resolves the stagger's start order via [`resolve_order()`](./anima-stagger.md#resolve_order) and schedules each target to start `interval` seconds after the previous one. Each entry drives its own target, taken from `AnimaStagger.targets` — the `target` node passed into this instance's own `advance()` is ignored.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaStaggerInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Starts and advances each target on its scheduled offset. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances the elapsed clock, starts any target whose scheduled offset has now been reached, and advances every already-started target that hasn't finished. Returns `true` once every target has finished (or immediately if `template` is unset or `targets` is empty). The `target` parameter is ignored — each entry animates its own node from `AnimaStagger.targets` instead.

## Related API

- [`AnimaStagger`](./anima-stagger.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_stagger_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_stagger_instance.gd)
