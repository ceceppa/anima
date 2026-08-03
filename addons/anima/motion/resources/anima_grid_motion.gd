## Plays one shared item motion across a tiled target collection, starting
## from a chosen grid cell and propagating outward per [member distance_formula].
##
## A specialised [AnimaGroupMotion] — it reuses target resolution, filters,
## the item motion, distributions, execution records, playback, validation,
## and compilation. The inherited [member order] still drives the same
## Top/Bottom/Center/Together/Odd/Even/Random/Index modes any group has;
## [member distance_formula] is a separate, additional scheduling path layered
## on top of the grid's own 2D shape (`tech-spec.md` §Grid motion contract).
##
## ```gdscript
## var grid := AnimaGridMotion.new()
## grid.target_collection = AnimaTargetCollection.new()
## grid.grid_dimensions = Vector2i(5, 5)
## grid.start_point = Vector2i(2, 2)
## grid.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
## grid.item_motion = Anima.item().opacity(1.0, 0.3)
## ```
class_name AnimaGridMotion
extends AnimaGroupMotion

## How distance from [member start_point] is measured, deciding which cells
## start together as one wave and in what order the waves propagate. See
## `tech-spec.md` §Grid motion contract for each formula's exact traversal.
enum DistanceFormula {
	## Straight-line distance from the start point.
	EUCLIDEAN,
	## Horizontal plus vertical distance.
	MANHATTAN,
	## The larger of horizontal or vertical distance.
	CHEBYSHEV,
	## Distance along the row axis only — the default; with [member start_point]
	## at row 0 this is the "starts from the top" propagation.
	ROW,
	## Distance along the column axis only.
	COLUMN,
	## Distance along the main diagonal.
	DIAGONAL,
	## Distance along the anti-diagonal.
	ANTI_DIAGONAL,
	## Polar-angle wave, clockwise from 12 o'clock around [member start_point].
	CLOCKWISE,
	## Polar-angle wave, anticlockwise from 12 o'clock around [member start_point].
	ANTICLOCKWISE,
	## Traversal that peels the grid's own rectangle inward from its corners,
	## in reverse — starts at the centre-most cell and expands outward,
	## finishing at the corner [constant SPIRAL_INWARD] starts from. Traces
	## the shape of the grid itself, not a wave from [member start_point] —
	## see [constant SPIRAL_INWARD].
	SPIRAL_OUTWARD,
	## The classic "spiral matrix" traversal: starts at the grid's top-left
	## corner and peels its rectangle inward one ring at a time — top row
	## left-to-right, right column top-to-bottom, bottom row right-to-left,
	## left column bottom-to-top, then the next ring in. This is the one
	## formula that ignores [member start_point]: the path comes from [member
	## grid_dimensions]'s own rectangle, not from a chosen point.
	SPIRAL_INWARD,
	## Alternating row-wise traversal, reversing direction on each successive row.
	SERPENTINE_ROW,
	## Alternating column-wise traversal, reversing direction on each successive column.
	SERPENTINE_COLUMN,
}

## Which way [constant DistanceFormula.SPIRAL_OUTWARD] and [constant
## DistanceFormula.SPIRAL_INWARD] wind. Unused by every other formula —
## [constant DistanceFormula.CLOCKWISE] and [constant DistanceFormula.ANTICLOCKWISE]
## already name their own direction.
enum SpiralDirection {
	CLOCKWISE,
	COUNTERCLOCKWISE,
}

## The authored grid width and height. Both must be positive. Resolved
## targets fill cells in row-major order; a partially filled final row is
## valid and does not change these dimensions.
@export var grid_dimensions: Vector2i = Vector2i(1, 1)
## The zero-based grid coordinate [member distance_formula] measures distance
## from. Must be inside [member grid_dimensions].
@export var start_point: Vector2i = Vector2i.ZERO
## The formula used to derive each cell's wave from [member start_point].
@export var distance_formula: DistanceFormula = DistanceFormula.ROW
## The winding direction for the two spiral formulas.
@export var spiral_direction: SpiralDirection = SpiralDirection.CLOCKWISE

## Defaults [member AnimaGroupMotion.order]'s [member AnimaGroupOrder.kind] to
## [constant AnimaGroupOrder.Kind.GRID] — the trigger [AnimaGroupScheduler]
## uses to rank this motion through [member distance_formula] instead of a
## plain group's flat-list ordering. An author can still override [member
## AnimaGroupMotion.order] directly (e.g. to `REVERSE` for "Bottom", or
## `RANDOM`) to fall back to that same standard ordering any other group has —
## see `tech-spec.md` §Group animation semantics.
func _init() -> void:
	order.kind = AnimaGroupOrder.Kind.GRID

## Adds grid-specific checks to the inherited [method AnimaGroupMotion.validate]:
## positive dimensions, and a start point inside them.
func validate() -> Array[String]:
	var errors := super.validate()
	if grid_dimensions.x <= 0 or grid_dimensions.y <= 0:
		errors.append("grid_dimensions must have a positive width and height")
		return errors

	if start_point.x < 0 or start_point.x >= grid_dimensions.x \
		or start_point.y < 0 or start_point.y >= grid_dimensions.y:
		errors.append("start_point must be inside grid_dimensions")
	return errors
