---
weight: 220
title: "AnimaRaceInstance"
description: "The internal runtime behaviour behind AnimaRace."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaRaceInstance

`AnimaRaceInstance` is the internal class that advances every enabled child of an [`AnimaRace`](./anima-race.md) each frame and completes as soon as the fastest one finishes. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaRaceInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaRace`](./anima-race.md), Anima creates one of these behind the scenes to advance every enabled child in step and report completion the moment any one of them finishes.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaRaceInstance
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

Advances every enabled child that hasn't finished yet, then returns `true` as soon as any child has finished. Once this returns `true`, the caller stops calling `advance()` on this instance — which is how the remaining, slower children are effectively cancelled: they simply never advance again, left wherever they happened to reach.

## Related API

- [`AnimaRace`](./anima-race.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_race_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_race_instance.gd)
