---
title: "Multiple animations"
description: "Combining animations with .then() and .with()"
---

Chaining a second call directly onto `Anima.on()` (`.opacity().position()`)
doesn't work — the first call already returns a built motion, not the
factory it came from. To combine more than one change, build each motion
separately and combine them explicitly:

```gdscript
var move := Anima.on($Card).position(Vector2(0, 0), 0.3)
var fade := Anima.on($Card).opacity(1.0, 0.2)

var one_after_another := move.then(fade)   # move finishes, then fade plays
var together := move.with(fade)            # move and fade play at the same time

one_after_another.play()
```

Chaining more than one `.with()` after a `.then()` joins a single group, not
nested pairs — `a.then(b).with(c).with(d)` means `b`, `c`, and `d` all start
together, right after `a` finishes.

## Adding a pause between steps

`.wait(seconds)` delays whatever comes *next* in the chain, without giving
that next motion its own `delay` field:

```gdscript
var reveal := move.wait(0.5).then(fade)   # move, wait half a second, then fade
```

If the next motion already has its own delay (e.g. from `.with_delay()`),
the two stack rather than one overriding the other.

## Playing many targets together

`.then()`/`.with()` combine motions on potentially different targets, but
for animating a whole group of nodes the same way, `Anima.group()`/
`Anima.grid()` are usually a better fit than composing per-node motions by
hand — see the generated [Anima](../../anima/anima) reference for
`Anima.group()`/`Anima.grid()`.
