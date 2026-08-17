---
title: "01: Basic Animation"
description: "Your first Anima animation, from an empty scene to a working fade-in"
weight: 1
---

This tutorial takes you from an empty Godot scene to a working animation,
using nothing but Anima's `Anima.on()` entry point.

## 1. Set up a scene

Create a new scene with a `Control` root, and add a `Label` as its child.
Give the `Label` some text (for example `"Hello, Anima"`) so there's
something visible to animate. Attach a new script to the root `Control`.

## 2. Play your first animation

In the root's script, fade the label in from fully transparent to fully
opaque over half a second:

```gdscript
extends Control

func _ready() -> void:
    var fade_in := Anima.on($Label).opacity(1.0).from(0.0).with_duration(0.5)
    fade_in.play()
```

Run the scene. The label starts invisible and fades in over half a second.

## 3. What just happened

- `Anima.on($Label)` starts building a motion targeting the label.
- `.opacity(1.0)` sets the value it animates *to* — fully opaque.
- `.from(0.0)` sets the value it animates *from* — fully transparent. Leaving
  `.from()` off entirely would instead capture whatever the label's current
  opacity already was when the animation started.
- `.with_duration(0.5)` sets how long it takes, in seconds.
- `Anima.on()` only builds the motion — nothing plays until you call
  `.play()` on it.

## 4. Try another property

Anima has a named method for most common properties. Try animating position
instead:

```gdscript
var slide_in := Anima.on($Label).move_by(Vector2(0, -20), 0.5)
slide_in.play()
```

`move_by()` animates *relative* to wherever the label currently is — see
[Animate relative values](../../guides/animating-relative-values) for more
on the difference between an absolute and a relative animation.

## Next

[02: Popup Animation](../02-popup-animation) builds on this scene, combining
more than one animation into a single sequential effect.
