---
weight: 230
title: "AnimaRepeatInstance"
description: "The internal runtime behaviour behind AnimaRepeat."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaRepeatInstance

`AnimaRepeatInstance` is the internal class that replays an [`AnimaRepeat`](./anima-repeat.md)'s `child` the configured number of times, waiting `delay_between` seconds between repeats. It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaRepeatInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaRepeat`](./anima-repeat.md), Anima creates one of these behind the scenes to track which repeat is currently playing, wait out any delay between repeats, and build each repeat's runtime instance — reversing `child`'s `from_value`/`to_value` on alternating repeats when [`alternate`](./anima-repeat.md#alternate) is set and `child` is an [`AnimaPropertyMotion`](./anima-property-motion.md).

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaRepeatInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances the current repeat, and starts the next one once it finishes. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

Advances the currently-playing repeat. Once a repeat finishes, either waits out `delay_between` before starting the next one, or returns `true` if that was the last repeat. Returns `true` immediately, without advancing anything, if `child` is unset or `count` is `0` or less.

## Related API

- [`AnimaRepeat`](./anima-repeat.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_repeat_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_repeat_instance.gd)
