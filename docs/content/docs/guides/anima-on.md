---
title: "Anima.on"
description: "Every method Anima.on() gives you for animating a single node"
---

`Anima.on(target)` hides the same thing every animation ultimately needs —
a property path, a start value, an end value, a duration, an easing curve
— behind short, named methods for the properties you animate most. This
page covers everything it exposes.

```gdscript
var factory := Anima.on($Card)
```

## Semantic setters

Each of these builds and returns an `AnimaPropertyMotion` ready to
`.play()`. `duration` defaults to `0.0`, which resolves through the
project's own default-duration chain when left unset.

```gdscript
Anima.on($Card).position(Vector2(200, 0), 0.3).play()      # move to an absolute position
Anima.on($Card).position_x(200.0, 0.3).play()               # just the x component
Anima.on($Card).position_y(0.0, 0.3).play()                 # just the y component
Anima.on($Node3D).position_z(5.0, 0.3).play()                # z — Node3D targets only

Anima.on($Card).move_by(Vector2(40, 0), 0.3).play()          # relative to wherever it is now

Anima.on($Card).scale(Vector2(1.2, 1.2), 0.2).play()         # scale to an absolute value
Anima.on($Card).scale_by(Vector2(0.1, 0.1), 0.2).play()      # scale relative to its current scale

Anima.on($Card).rotation(PI, 0.3).play()                     # rotate to an absolute angle (radians)
Anima.on($Card).rotate_by(PI / 4, 0.3).play()                 # rotate relative to its current angle

Anima.on($Card).opacity(1.0, 0.3).play()                     # fade to an alpha value
Anima.on($Card).color(Color.RED, 0.3).play()                 # tint to an absolute Color

Anima.on($Panel).size(Vector2(300, 200), 0.3).play()          # Control targets only

Anima.on($Card).property(^"modulate:b", 0.5, 0.2).play()      # any property, by path
Anima.on($Card).property_by(^"modulate:a", -0.2, 0.2).play()  # relative, by path

Anima.on($Card).keyframes({                                   # more than two stops — see the Keyframes guide
    "from": {"scale": Vector2(0.8, 0.8)},
    50: {"scale": Vector2(1.1, 1.1)},
    "to": {"scale": Vector2.ONE},
}, 0.4).play()
```

`.rotation()`/`.rotate_by()` only work on `Control`/`Node2D` (2D rotation is
one number); use `.property()` for a `Node3D`'s 3-axis rotation instead.
`.position_z()`/`.size()` similarly only apply to the target types that
actually have that axis/property.

## Modifiers

Chain these onto whatever a semantic setter above returned, before
`.play()`:

```gdscript
Anima.on($Card).opacity(1.0).from(0.0)                        # explicit start value
Anima.on($Card).opacity(1.0).from_current()                   # capture current value at motion start (the default when .from() is never called)

Anima.on($Card).opacity(1.0).with_duration(0.5)                # seconds
Anima.on($Card).opacity(1.0).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
Anima.on($Card).opacity(1.0).with_delay(0.2)                   # wait before starting

Anima.on($Card).property(^"modulate:a", 0.2).relative()        # add instead of replace, for a method with no _by variant
Anima.on($Card).scale(Vector2(1.2, 1.2)).with_pivot(AnimaPivot.Kind.CENTER)
```

## Playing it, and combining more than one

`.play()` is the convenience form — reachable because `Anima.on()` already
captured `$Card` as the target, so you never repeat it:

```gdscript
var fade := Anima.on($Card).opacity(1.0, 0.3)
fade.play()
```

Combine more than one motion with `.then()` (one after another) or `.with()`
(together) — see [Multiple animations](multiple-animations) for the full
story. Every motion, however built, also has:

```gdscript
Anima.on($Card).opacity(1.0).on_started(func(): print("started"))
Anima.on($Card).opacity(1.0).on_completed(func(): print("done"))
Anima.on($Card).opacity(1.0).repeat(3, true)   # 3 times, alternating direction
Anima.on($Card).opacity(1.0).with_speed(2.0)   # playback rate multiplier
Anima.on($Card).opacity(1.0).wait(0.5).then(Anima.on($Card).scale(Vector2.ONE))
```

`.play()` returns an `AnimaPlayback` with its own `.complete()`, `.revert()`,
`.cancel()`, and `.reverse()` — see the generated
[AnimaPlayback](../../anima/anima-playback) reference for that surface.

See the generated [Anima](../../anima/anima) and
[AnimaOnMotionFactory](../../anima/anima-on-motion-factory) reference pages
for exact signatures and failure behaviour.
