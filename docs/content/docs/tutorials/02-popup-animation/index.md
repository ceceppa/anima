---
title: "02: Popup Animation"
description: "A sequential pop-in-then-settle effect, building on the fade from 01"
weight: 2
---

This tutorial continues the scene from
[01: Basic Animation](../01-basic-animation) — the same `Control` root with a
`Label` child — and combines more than one animation into a single
sequential "popup" effect: the label grows in with a bounce, then settles.

## 1. Build two motions

A popup effect is two changes happening one after another: a quick
overshoot, then a settle back to normal size. Build each as its own motion:

```gdscript
extends Control

func _ready() -> void:
    var grow := Anima.on($Label).scale(Vector2(1.15, 1.15)) \
        .from(Vector2.ZERO).with_duration(0.25) \
        .with_ease(AnimaEase.Kind.EASE_OUT_BACK)
    var settle := Anima.on($Label).scale(Vector2.ONE, 0.15)
```

## 2. Combine them sequentially

`.then()` plays `settle` only once `grow` has finished — exactly the
overshoot-then-settle shape a popup needs:

```gdscript
    var popup := grow.then(settle)
    popup.play()
```

Run the scene. The label grows from nothing past its normal size, then
eases back down to rest — a distinct result from 01's plain fade-in, built
the same way: small motions, combined explicitly.

## 3. What's different from 01

- 01 played one motion. This tutorial builds two (`grow`, `settle`) and
  combines them with `.then()` — see
  [Multiple animations](../../guides/multiple-animations) for `.with()`,
  the "play together" alternative to `.then()`'s "play one after another".
- `.with_ease(AnimaEase.Kind.EASE_OUT_BACK)` gives `grow` its overshoot —
  see [Built-in Easings](../../features/built-in-easings) for the full set
  of named curves.
- Nothing here needed keyframes — two combined two-stop motions are enough
  for a popup. See [Keyframes](../../guides/keyframes) for when you need
  more than two stops in a single motion instead of two combined ones.
