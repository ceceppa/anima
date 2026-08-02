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

	var ranks := _compute_ranks(group.order, targets.size())

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
## [param order]'s [member AnimaGroupOrder.kind].
static func _compute_ranks(order: AnimaGroupOrder, count: int) -> Array[int]:
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
