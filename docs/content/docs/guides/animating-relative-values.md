---
title: "Animate relative values"
description: "Animating by how much a value changes, not to a fixed destination"
---

Most `Anima.on()` methods animate *to* an absolute value — `.position(Vector2(200, 0))`
always ends at `(200, 0)`, no matter where the target started. Sometimes you
want the opposite: move a target 40 pixels from wherever it currently is,
whatever that happens to be.

The `_by` variants do exactly that:

```gdscript
Anima.on($Card).move_by(Vector2(40, 0), 0.3)     # 40px right of its current position
Anima.on($Card).scale_by(Vector2(0.1, 0.1), 0.2)  # 10% larger than its current scale
Anima.on($Card).rotate_by(PI / 4, 0.3)            # rotated 45° further than it is now
```

Each of these is a normal `AnimaPropertyMotion` with one field set —
`is_relative = true` — which changes how the animated end value is
resolved: instead of replacing the target's starting value, the authored
`to` value is *added* to whatever the target's own value actually was when
the motion started.

## On the generic escape hatch

`.property()` reaches any property by path but animates to an absolute
value by default, same as the named methods. `.relative()` gives it the
same "add instead of replace" behaviour:

```gdscript
Anima.on($Card).property(^"modulate:a", 0.2).relative()
```

See [Dynamic Value](dynamic-values) for the related but different case of
reading a *live* property value as an operand, rather than adding a fixed
delta to whatever the start value turns out to be.
