## Turns a resolved target list into a concrete, repeatable start schedule.
##
## [AnimaGroupOrder] describes an author's ordering choice in the abstract
## ("centred", "random with this seed", …). This helper turns that choice,
## together with an [AnimaGroupDistribution] and playback mode, into the
## actual per-target schedule group playback reads: which target starts
## first, which targets start together as a wave, and — for a staggered
## group — how many seconds after the group begins each one starts. It does
## not run anything; see [AnimaGroupMotion] for playing a group.
class_name AnimaGroupScheduler
extends RefCounted

## One target's place in a derived schedule.
class ScheduleEntry:
	## The scheduled target.
	var target: Node
	## This target's position in the resolved list passed to [method derive],
	## before ordering. Used to break ties between same-rank targets so the
	## schedule stays a stable, repeatable sequence.
	var original_index: int = 0
	## This target's wave. Targets that share a rank start together; a lower
	## rank always starts no later than a higher one.
	var rank: int = 0
	## Seconds after the group begins that this target starts. Only
	## meaningful for [constant AnimaGroupMotion.PlaybackMode.STAGGERED] —
	## always `0.0` for [constant AnimaGroupMotion.PlaybackMode.PARALLEL],
	## and unused for [constant AnimaGroupMotion.PlaybackMode.SEQUENTIAL],
	## whose real start times depend on each item's actual completion instead
	## of a precomputed offset.
	var start_offset: float = 0.0

## A complete, ready-to-play schedule for one group execution.
class Schedule:
	## Every scheduled target, already sorted into start order — the target
	## that starts first is [code]entries[0][/code]. Ties (same [member
	## ScheduleEntry.rank]) are broken by [member ScheduleEntry.original_index].
	var entries: Array[ScheduleEntry] = []
	## The random seed this schedule was derived with. Only meaningful when
	## the owning [AnimaGroupOrder]'s [member AnimaGroupOrder.kind] is
	## [constant AnimaGroupOrder.Kind.RANDOM]; kept here regardless so a
	## caller can always trace or replay a schedule without reaching back
	## into the resource.
	var seed: int = 0

## Derives a [Schedule] for [param targets] using [param group]'s configured
## [member AnimaGroupMotion.order], [member AnimaGroupMotion.distribution],
## and [member AnimaGroupMotion.playback_mode].
##
## [param targets] should already be resolved and filtered — this only
## orders and schedules the list it's given; it does not resolve a target
## collection itself. Calling this again with the same [param group]
## configuration and the same [param targets] always produces the same
## [Schedule], including for a [constant AnimaGroupOrder.Kind.RANDOM] order
## with a fixed [member AnimaGroupOrder.seed].
static func derive(group: AnimaGroupMotion, targets: Array[Node]) -> Schedule:
	var schedule := Schedule.new()
	schedule.seed = group.order.seed
	if targets.is_empty():
		return schedule

	var ranks := _compute_ranks(group, targets.size())

	for index in targets.size():
		var entry := ScheduleEntry.new()
		entry.target = targets[index]
		entry.original_index = index
		entry.rank = ranks[index]
		schedule.entries.append(entry)

	schedule.entries.sort_custom(func(a: ScheduleEntry, b: ScheduleEntry) -> bool:
		return a.rank < b.rank if a.rank != b.rank else a.original_index < b.original_index
	)
	_apply_start_offsets(schedule.entries, group)
	return schedule

static func _apply_start_offsets(entries: Array[ScheduleEntry], group: AnimaGroupMotion) -> void:
	if group.playback_mode != AnimaGroupMotion.PlaybackMode.STAGGERED:
		for entry in entries:
			entry.start_offset = 0.0
		return

	var distribution := group.distribution
	var max_rank := 0
	for entry in entries:
		max_rank = maxi(max_rank, entry.rank)

	for entry in entries:
		if distribution.mode == AnimaGroupDistribution.Mode.TOTAL_DURATION:
			entry.start_offset = 0.0 if max_rank == 0 else (float(entry.rank) / float(max_rank)) * distribution.total_stagger_duration
		else:
			entry.start_offset = float(entry.rank) * distribution.stagger_interval

## Returns one rank per resolved position, `0..count - 1`, following
## [param group]'s [member AnimaGroupMotion.order] [member AnimaGroupOrder.kind].
## An [AnimaGridMotion] (which defaults its own [member AnimaGroupOrder.kind]
## to [constant AnimaGroupOrder.Kind.GRID]) upgrades that kind to its richer
## [member AnimaGridMotion.distance_formula] system instead of the plain
## [method _ranks_grid] every other group still gets for that kind.
static func _compute_ranks(group: AnimaGroupMotion, count: int) -> Array[int]:
	var order := group.order
	match order.kind:
		AnimaGroupOrder.Kind.REVERSE:
			return _ranks_reverse(count)
		AnimaGroupOrder.Kind.CENTRED:
			return _ranks_centred(count)
		AnimaGroupOrder.Kind.EDGE:
			return _ranks_edge(count)
		AnimaGroupOrder.Kind.RANDOM:
			return _ranks_random(order.seed, count)
		AnimaGroupOrder.Kind.GRID:
			if group is AnimaGridMotion:
				return _ranks_grid_formula(group as AnimaGridMotion, count)
			return _ranks_grid(order, count)
		AnimaGroupOrder.Kind.DISTANCE:
			return _ranks_distance(order, count)
		_:
			# FORWARD, and the reserved EXPLICIT/CUSTOM kinds, which have no
			# supporting configuration yet — see their doc comments.
			return _ranks_forward(count)

static func _ranks_forward(count: int) -> Array[int]:
	var ranks: Array[int] = []
	for index in count:
		ranks.append(index)
	return ranks

static func _ranks_reverse(count: int) -> Array[int]:
	var ranks: Array[int] = []
	for index in count:
		ranks.append(count - 1 - index)
	return ranks

static func _ranks_edge(count: int) -> Array[int]:
	var ranks: Array[int] = []
	for index in count:
		ranks.append(mini(index, count - 1 - index))
	return ranks

static func _ranks_centred(count: int) -> Array[int]:
	var center := float(count - 1) / 2.0
	var ranks: Array[int] = []
	for index in count:
		ranks.append(int(floor(absf(float(index) - center))))
	return ranks

static func _ranks_random(random_seed: int, count: int) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	var shuffled: Array[int] = []
	for index in count:
		shuffled.append(index)
	for index in range(count - 1, 0, -1):
		var swap_with := rng.randi_range(0, index)
		var tmp := shuffled[index]
		shuffled[index] = shuffled[swap_with]
		shuffled[swap_with] = tmp

	var ranks: Array[int] = []
	ranks.resize(count)
	for position in count:
		ranks[shuffled[position]] = position
	return ranks

## A 1D "distance from an origin position in the resolved list" ranking,
## shared by [constant AnimaGroupOrder.Kind.DISTANCE]. [param origin]'s
## [constant AnimaGroupOrder.Origin.POINT] is read as a fractional list
## position ([member AnimaGroupOrder.origin_point]'s `x`) rather than a
## scene position, since a resolved target has no guaranteed spatial
## transform to measure against.
static func _ranks_distance(order: AnimaGroupOrder, count: int) -> Array[int]:
	var origin_position := _resolve_1d_origin(order, count)
	var ranks: Array[int] = []
	for index in count:
		ranks.append(int(floor(absf(float(index) - origin_position))))
	return ranks

static func _resolve_1d_origin(order: AnimaGroupOrder, count: int) -> float:
	match order.origin:
		AnimaGroupOrder.Origin.LAST:
			return float(count - 1)
		AnimaGroupOrder.Origin.CENTER:
			return float(count - 1) / 2.0
		AnimaGroupOrder.Origin.INDEX:
			return float(clampi(order.origin_index, 0, count - 1))
		AnimaGroupOrder.Origin.POINT:
			return clampf(order.origin_point.x, 0.0, float(count - 1))
		_:
			return 0.0

## A 2D "distance from an origin cell in a virtual [member
## AnimaGroupOrder.grid_columns]-wide grid" ranking for [constant
## AnimaGroupOrder.Kind.GRID]. The grid is virtual — it maps resolved-list
## position to a row/column, independent of each target's actual transform —
## since a resolved target has no guaranteed spatial layout to measure
## against.
static func _ranks_grid(order: AnimaGroupOrder, count: int) -> Array[int]:
	var columns := maxi(order.grid_columns, 1)
	var origin_cell := _resolve_grid_origin(order, count, columns)

	var ranks: Array[int] = []
	for index in count:
		var cell := Vector2(float(index % columns), float(index / columns))
		ranks.append(int(floor(cell.distance_to(origin_cell))))
	return ranks

static func _resolve_grid_origin(order: AnimaGroupOrder, count: int, columns: int) -> Vector2:
	match order.origin:
		AnimaGroupOrder.Origin.LAST:
			var last_index := count - 1
			return Vector2(float(last_index % columns), float(last_index / columns))
		AnimaGroupOrder.Origin.CENTER:
			var rows := int(ceil(float(count) / float(columns)))
			return Vector2(float(columns - 1) / 2.0, float(rows - 1) / 2.0)
		AnimaGroupOrder.Origin.INDEX:
			var index := clampi(order.origin_index, 0, count - 1)
			return Vector2(float(index % columns), float(index / columns))
		AnimaGroupOrder.Origin.POINT:
			return order.origin_point
		_:
			return Vector2.ZERO

## Ranks a resolved list against [param grid]'s own 2D shape and [member
## AnimaGridMotion.distance_formula] — see `tech-spec.md` §Grid motion
## contract for each formula's exact traversal. Resolved targets fill cells
## in row-major order using [member AnimaGridMotion.grid_dimensions]; a
## partially filled final row is valid.
static func _ranks_grid_formula(grid: AnimaGridMotion, count: int) -> Array[int]:
	var columns := maxi(grid.grid_dimensions.x, 1)
	var rows := maxi(grid.grid_dimensions.y, 1)

	if grid.distance_formula == AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD \
		or grid.distance_formula == AnimaGridMotion.DistanceFormula.SPIRAL_INWARD:
		return _ranks_spiral(grid, count, columns, rows)

	var start := Vector2(grid.start_point.x, grid.start_point.y)
	var raw_ranks: Array[int] = []
	for index in count:
		var row := index / columns
		var col := index % columns
		var cell := Vector2(float(col), float(row))
		raw_ranks.append(_grid_formula_rank(grid, cell, start, row, col, columns, rows))
	return _densify_ranks(raw_ranks)

## Ranks every resolved cell by its position along a clockwise (or, per
## [member AnimaGridMotion.spiral_direction], anticlockwise) traversal that
## peels [param columns] × [param rows] rectangle inward from its own
## corners, one ring at a time — the classic "spiral matrix" order, starting
## at the top-left corner. [constant AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD]
## is that same path in reverse (innermost cell first, outward to the corner
## it started from). Unlike every other formula, this path comes from the
## grid's own rectangle, not from [member AnimaGridMotion.start_point] — a
## spiral anchored at an arbitrary interior point stops tracing a rectangle
## the moment it reaches that point's own edge, which reads as broken rather
## than as a grid-shaped spiral.
static func _ranks_spiral(grid: AnimaGridMotion, count: int, columns: int, rows: int) -> Array[int]:
	var path := _spiral_path(columns, rows, grid.spiral_direction == AnimaGridMotion.SpiralDirection.COUNTERCLOCKWISE)
	if grid.distance_formula == AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD:
		path.reverse()

	var rank_by_cell := {}
	for i in path.size():
		rank_by_cell[path[i]] = i

	var ranks: Array[int] = []
	for index in count:
		var row := index / columns
		var col := index % columns
		ranks.append(rank_by_cell.get(Vector2i(col, row), path.size()))
	return ranks

## Clockwise (or, mirrored, anticlockwise) spiral cell order for a [param
## columns] × [param rows] rectangle, starting at its top-left corner and
## peeling inward one ring at a time.
static func _spiral_path(columns: int, rows: int, counterclockwise: bool) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var top := 0
	var bottom := rows - 1
	var left := 0
	var right := columns - 1

	while top <= bottom and left <= right:
		if counterclockwise:
			for row in range(top, bottom + 1):
				path.append(Vector2i(left, row))
			left += 1
			for col in range(left, right + 1):
				path.append(Vector2i(col, bottom))
			bottom -= 1
			if left <= right:
				for row in range(bottom, top - 1, -1):
					path.append(Vector2i(right, row))
				right -= 1
			if top <= bottom:
				for col in range(right, left - 1, -1):
					path.append(Vector2i(col, top))
				top += 1
		else:
			for col in range(left, right + 1):
				path.append(Vector2i(col, top))
			top += 1
			for row in range(top, bottom + 1):
				path.append(Vector2i(right, row))
			right -= 1
			if top <= bottom:
				for col in range(right, left - 1, -1):
					path.append(Vector2i(col, bottom))
				bottom -= 1
			if left <= right:
				for row in range(bottom, top - 1, -1):
					path.append(Vector2i(left, row))
				left += 1
	return path

## Remaps arbitrary (but order- and tie-preserving) rank keys to a dense
## `0..distinct-1` sequence. [constant AnimaGridMotion.DistanceFormula.CLOCKWISE]/
## [constant AnimaGridMotion.DistanceFormula.ANTICLOCKWISE] encode a bearing
## in thousandths of a radian, and the two spiral formulas encode a distance
## *and* a bearing into one key — both raw magnitudes are far larger than the
## actual number of waves. Left un-densified, [method _apply_start_offsets]'s
## `rank * stagger_interval` turns that raw magnitude directly into a
## multi-thousand-second start delay, which is why those formulas looked like
## they "didn't work" — the wave was scheduled to start long after any real
## playback or test ever advances that far.
static func _densify_ranks(raw_ranks: Array[int]) -> Array[int]:
	var distinct := raw_ranks.duplicate()
	distinct.sort()
	var dense_by_raw := {}
	var next_dense := 0
	for value in distinct:
		if not dense_by_raw.has(value):
			dense_by_raw[value] = next_dense
			next_dense += 1

	var dense_ranks: Array[int] = []
	for value in raw_ranks:
		dense_ranks.append(dense_by_raw[value])
	return dense_ranks

static func _grid_formula_rank(grid: AnimaGridMotion, cell: Vector2, start: Vector2, row: int, col: int, columns: int, rows: int) -> int:
	match grid.distance_formula:
		AnimaGridMotion.DistanceFormula.MANHATTAN:
			return int(absf(cell.x - start.x) + absf(cell.y - start.y))
		AnimaGridMotion.DistanceFormula.CHEBYSHEV:
			return int(maxf(absf(cell.x - start.x), absf(cell.y - start.y)))
		AnimaGridMotion.DistanceFormula.ROW:
			return int(absf(cell.y - start.y))
		AnimaGridMotion.DistanceFormula.COLUMN:
			return int(absf(cell.x - start.x))
		AnimaGridMotion.DistanceFormula.DIAGONAL:
			return int(absf((cell.x - cell.y) - (start.x - start.y)))
		AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL:
			return int(absf((cell.x + cell.y) - (start.x + start.y)))
		AnimaGridMotion.DistanceFormula.CLOCKWISE:
			return _angular_rank(cell, start, true)
		AnimaGridMotion.DistanceFormula.ANTICLOCKWISE:
			return _angular_rank(cell, start, false)
		AnimaGridMotion.DistanceFormula.SERPENTINE_ROW:
			return row * columns + (col if row % 2 == 0 else columns - 1 - col)
		AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN:
			return col * rows + (row if col % 2 == 0 else rows - 1 - row)
		_:
			# EUCLIDEAN, the default.
			return int(floor(cell.distance_to(start)))

## Bearing of [param cell] from [param start], in radians clockwise from 12
## o'clock (`0`), increasing clockwise, wrapped to `0..TAU`. The start cell
## itself (zero offset) has no defined angle and reports `0.0`.
static func _clockwise_bearing(cell: Vector2, start: Vector2) -> float:
	var offset := cell - start
	if offset == Vector2.ZERO:
		return 0.0
	var bearing := atan2(offset.x, -offset.y)
	if bearing < 0.0:
		bearing += TAU
	return bearing

## Shared angular rank for [constant AnimaGridMotion.DistanceFormula.CLOCKWISE]
## and [constant AnimaGridMotion.DistanceFormula.ANTICLOCKWISE] — cells at the
## same angle from [param start] share a rank, an intentional simultaneous
## wave; the start cell itself always ranks first, ahead of the angular sweep.
static func _angular_rank(cell: Vector2, start: Vector2, clockwise: bool) -> int:
	if cell == start:
		return -1
	var bearing := _clockwise_bearing(cell, start)
	if not clockwise:
		bearing = fposmod(TAU - bearing, TAU)
	return int(round(bearing * 1000.0))
