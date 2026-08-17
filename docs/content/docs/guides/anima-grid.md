---
title: "Anima.grid"
description: "Every method Anima.grid() gives you for animating a grid-shaped set of nodes"
---

`Anima.grid(container)` is `Anima.group()` specialised for a
`GridContainer`-shaped layout, where each item's own row/column position can
drive *when* it starts — a ripple, a diagonal sweep, a spiral. This page
covers everything the factory exposes.

## Setting it up

```gdscript
Anima.grid($InventoryGrid)                    # column count inferred from the GridContainer
Anima.grid($InventoryGrid, Vector2i(4, 3))     # or state the grid size explicitly
```

## The fastest path: a named preset

Each of these sets the item motion's start pattern *and*, if nothing else
already gave the item motion a shape, supplies a sensible default motion —
so a single preset call is a complete, playable animation:

```gdscript
Anima.grid($InventoryGrid).radial().play()             # ripples out from the start point
Anima.grid($InventoryGrid).diamond().play()
Anima.grid($InventoryGrid).box().play()
Anima.grid($InventoryGrid).by_row().play()
Anima.grid($InventoryGrid).by_column().play()
Anima.grid($InventoryGrid).diagonal().play()
Anima.grid($InventoryGrid).anti_diagonal().play()
Anima.grid($InventoryGrid).clockwise().play()
Anima.grid($InventoryGrid).counter_clockwise().play()
Anima.grid($InventoryGrid).spiral_in().play()
Anima.grid($InventoryGrid).spiral_out().play()
Anima.grid($InventoryGrid).serpentine_row().play()
Anima.grid($InventoryGrid).serpentine_column().play()
```

Each preset is pure sugar for `.with_distance_formula(DistanceFormula.X)` —
calling one directly instead is equivalent, just without the free default
motion:

```gdscript
Anima.grid($InventoryGrid).with_distance_formula(AnimaGridMotion.DistanceFormula.RADIAL)
```

## Your own item motion

Supplying your own item motion before or instead of a preset works the same
way `Anima.group()` does:

```gdscript
Anima.grid($InventoryGrid) \
    .keyframes({"from": {"scale": Vector2.ZERO}, "to": {"scale": Vector2.ONE}}, 0.3) \
    .radial() \
    .play()
```

Setting `item_motion` *before* calling a preset means the preset's own
"still empty?" check finds it already set and leaves it alone — your motion
always wins over a preset's default.

## Shaping the item motion further

```gdscript
Anima.grid($InventoryGrid).radial().with_duration(0.5)
Anima.grid($InventoryGrid).radial().with_ease(AnimaEase.Kind.EASE_OUT_BACK)
Anima.grid($InventoryGrid).radial().with_pivot(AnimaPivot.Kind.CENTER)
```

## Positioning the grid's own layout

```gdscript
Anima.grid($InventoryGrid).with_dimensions(Vector2i(4, 3))    # also re-centers start_point unless you've set one explicitly
Anima.grid($InventoryGrid).with_start_point(Vector2i(0, 0))   # e.g. ripple from a corner instead of the center
Anima.grid($InventoryGrid).with_stagger_interval(0.05)         # seconds between each item's own start
```

## Delay, callbacks, combining, playing

Identical to [Anima.group](anima-group)'s own equivalents — `.with_delay()`,
`.wait()`, `.on_started()`/`.on_completed()`, `.then()`/`.with()`, `.play()`,
and `.motion` for the raw resource:

```gdscript
Anima.grid($InventoryGrid).radial().with_delay(0.2).play()
Anima.grid($InventoryGrid).radial().wait(0.5).then(Anima.on($Label).fade_in(0.2))
```

## What the factory is convenience sugar over

`Anima.grid()` builds and configures an `AnimaGridMotion` — the same fields
`AnimaGroupMotion` has (`target_collection`, `item_motion`, and the rest —
see [Anima.group](anima-group)), plus `grid_dimensions`, `start_point`,
`distance_formula`, and `spiral_direction`. See the generated
[AnimaGridMotion](../../anima/anima-grid-motion) and
[AnimaGridMotionFactory](../../anima/anima-grid-motion-factory) reference
pages for the complete field/method list.
