---
title: "Keyframes"
description: "Authoring a multi-stop animation across one duration"
---

`Anima.on()`'s named methods (`.position()`, `.opacity()`, …) each animate
one property between exactly two values — a start and an end.
`AnimaKeyframeMotion` is for when you need more than two stops across one
timeline: a bounce that overshoots at 60% before settling, or several
properties changing together at different points along the same duration.

```gdscript
var pop := Anima.on($Card).keyframes({
    "from": {"scale": Vector2(0.8, 0.8)},
    50: {"scale": Vector2(1.1, 1.1)},
    "to": {"scale": Vector2.ONE},
}, 0.4)

pop.play()
```

Offsets are percentages along the motion's total duration — `"from"` is `0`,
`"to"` is `100`, and a bare number like `50` is the midpoint. Every property
named at any offset gets its own track, interpolated independently between
whichever stops it's actually declared at.

## Building it incrementally

The same resource can be built one offset at a time instead of one big
dictionary, useful when stops come from different parts of your code:

```gdscript
var pop := Motion.keyframes() \
    .at("from", {"scale": Vector2(0.8, 0.8)}) \
    .at(50, {"scale": Vector2(1.1, 1.1)}) \
    .at("to", {"scale": Vector2.ONE}) \
    .with_duration(0.4)
```

Both forms produce the identical resource — pick whichever reads better at
the call site.

## Per-stop easing, and other reserved keys

A stop's dictionary can include `_ease` to override the motion's overall
`default_ease` for the segment arriving at that stop, and `_pivot` to set
the pivot point a `scale`/`rotation` stop rotates or scales around (see the
generated [AnimaKeyframeTrack](../../anima/anima-keyframe-track) and
[AnimaKeyframeStop](../../anima/anima-keyframe-stop) reference pages for the
full per-stop field list):

```gdscript
Motion.keyframes({
    "from": {"rotation": 0.0},
    "to": {"rotation": PI, "_ease": AnimaEase.Kind.EASE_OUT_BACK},
})
```

## Duration doesn't have to be fixed

`duration` usually holds a plain number of seconds, but it can also hold a
dynamic [AnimaValue](dynamic-values) resolved once when the motion starts —
the built-in `typewrite` animation uses this so its reveal takes longer for
longer text instead of racing through it at a fixed pace:

```gdscript
Motion.keyframes({...}).with_duration(
    AnimaValue.target(^"text").length().multiply(0.1)
)
```

See the generated [AnimaKeyframeMotion](../../anima/anima-keyframe-motion)
reference for the complete member list.
