---
weight: 300
title: "Anima Addon"
description: "Anima addon structure and usage"
icon: "folder"
draft: false
---

## Getting started

The fastest way to animate a node is [`Anima.on()`](anima-on-motion-factory) — a
factory that builds the same [`AnimaPropertyMotion`](anima-property-motion)
resource writing one out by hand would, through a short, discoverable method
instead of a raw property path:

```gdscript
var fade_in := Anima.on($Panel).opacity(1.0).from(0.0).with_duration(0.3)
Anima.play(fade_in, $Panel)
```

`with_duration()`, `with_ease()`, and `with_delay()` use a `with_` prefix
rather than bare names — `duration`, `ease`, and `delay` are already field
names on the motion itself, and GDScript can't declare a method with the
same name as a property.

### Composing more than one change

Chaining a second `Anima.on()` call directly (`.opacity().position()`) isn't
supported — the first call already returns a motion, not the factory. Combine
motions explicitly with `then()` (one after another) or `with()` (together):

```gdscript
var reveal := Anima.on($Card).position(Vector2(0, 0), 0.3) \
    .then(Anima.on($Card).opacity(1.0, 0.2))          # move, then fade in
var reveal_together := Anima.on($Card).position(Vector2(0, 0), 0.3) \
    .with(Anima.on($Card).opacity(1.0, 0.3))          # move and fade in together

Anima.play(reveal, $Card)
```

Multiple `.with()` calls chained after one `.then()` join a single group —
`a.then(b).with(c).with(d)` is `b`, `c`, and `d` all starting together, after
`a` — not nested pairs.

### The escape hatch, and the equivalence underneath

Not every property has a named method. `.property()` reaches any property by
path, and delegates straight to the same `Motion.to()` builder direct
authoring uses:

```gdscript
var pulse := Anima.on($Card).property(NodePath("modulate:b"), 0.5, 0.2)
```

Every convenience method — including `.property()` — builds the exact same
kind of resource `Motion.to()` would. `Anima.on($Card).opacity(1.0)` and
`Motion.to(NodePath("modulate:a"), 1.0)` are two authoring styles for one
underlying motion, not two competing systems: either one plays, reverses,
composes, and compiles identically, and both are equally valid depending on
whether the named convenience method or the raw property path reads better
at the call site.

For a group of nodes, [`Anima.item()`](anima-item-motion-factory) offers the
same named methods as `Anima.on()` for an
[`AnimaGroupMotion`](anima-group-motion)'s shared item motion — see
[`AnimaGridMotion`](anima-grid-motion) for the grid-shaped case.
