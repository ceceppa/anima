---
title: "Reusable vs. Single-Shot"
description: "One authored motion, played many times — or duplicated for independent state"
---

An `AnimaMotion` is a `Resource`, not a one-time instruction — the same
authored motion can be played again and again, on the same target or on
different ones, without re-authoring it each time.

```gdscript
var fade_in := Anima.on($Card).opacity(1.0).from(0.0).with_duration(0.3)

fade_in.play()   # play it now
fade_in.play()   # play it again later — same resource, replayed
```

Every built-in catalog animation works this way by default:
`Anima.animation(name)` caches and returns the exact same shared resource on
every call — the same object whether you look it up by name or drag the
matching `.tres` into the Inspector yourself.

```gdscript
var a := Anima.animation("tada")
var b := Anima.animation("tada")
# a and b are the same Resource
```

## When you need independent state

Sharing one resource is fine as long as nothing about the motion changes
between plays. If you need to override something per-play — a different
speed, a different duration — without that change leaking into every other
place the same motion plays, duplicate it first:

```gdscript
var my_tada := Anima.animation("tada").duplicate(true) as AnimaMotion
var playback := Anima.play(my_tada, $Card)
playback.speed_scale = 2.0   # only this copy plays at double speed
```

`duplicate(true)` copies the whole resource tree (a deep copy), so changing
the copy never mutates the shared original — the same pattern the built-in
Animation Catalog Playground example uses every time it plays a preset.
