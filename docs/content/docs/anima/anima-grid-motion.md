---
title: "AnimaGridMotion"
description: "Plays one shared item motion across a tiled target collection, starting"
---

# AnimaGridMotion

## Overview

Plays one shared item motion across a tiled target collection, starting
from a chosen grid cell and propagating outward per [member distance_formula].

A specialised [AnimaGroupMotion] — it reuses target resolution, filters,
the item motion, distributions, execution records, playback, validation,
and compilation. The inherited [member order] still drives the same
Top/Bottom/Center/Together/Odd/Even/Random/Index modes any group has;
[member distance_formula] is a separate, additional scheduling path layered
on top of the grid's own 2D shape (`tech-spec.md` §Grid motion contract).

```gdscript
var grid := AnimaGridMotion.new()
grid.target_collection = AnimaTargetCollection.new()
grid.grid_dimensions = Vector2i(5, 5)
grid.start_point = Vector2i(2, 2)
grid.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
grid.item_motion = Anima.item().opacity(1.0, 0.3)
```

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### DistanceFormula

How distance from [member start_point] is measured, deciding which cells
start together as one wave and in what order the waves propagate. See
`tech-spec.md` §Grid motion contract for each formula's exact traversal.

### SpiralDirection

Which way [constant DistanceFormula.SPIRAL_OUTWARD] and [constant
DistanceFormula.SPIRAL_INWARD] wind. Unused by every other formula —
[constant DistanceFormula.CLOCKWISE] and [constant DistanceFormula.ANTICLOCKWISE]
already name their own direction.

## Properties and constants

### grid_dimensions

The authored grid width and height. Both must be positive. Resolved
targets fill cells in row-major order; a partially filled final row is
valid and does not change these dimensions.

### start_point

The zero-based grid coordinate [member distance_formula] measures distance
from. Must be inside [member grid_dimensions].

### distance_formula

The formula used to derive each cell's wave from [member start_point].

### spiral_direction

The winding direction for the two spiral formulas.

## Methods

### validate

Adds grid-specific checks to the inherited [method AnimaGroupMotion.validate]:
positive dimensions, and a start point inside them.
