## Runtime instance for [AnimaGroupMotion] — resolves its target collection
## once, derives a schedule, then advances every resolved target's own item
## motion according to the group's playback mode.
##
## Created automatically by [method AnimaGroupMotion.create_runtime]; not
## something you construct directly. Reach a running group through the
## [AnimaPlayback] [method Anima.play] returns — [member
## AnimaPlayback.speed_scale] and [method AnimaPlayback.reverse] are the
## supported ways to control one from outside.
class_name AnimaGroupPlayback
extends AnimaMotionInstance

class _ItemState:
	var target: Node
	var start_offset: float = 0.0
	var instance: Variant = null
	var started: bool = false
	var finished: bool = false
	## This item's position in start order — backs [member AnimaValueContext.group_index].
	var index: int = 0
	## This item's position in the resolved list before ordering — backs
	## [member AnimaValueContext.grid_row]/[member AnimaValueContext.grid_column].
	var original_index: int = 0

var _items: Array[_ItemState] = []
var _resolved := false
var _cancelled := false
var _elapsed: float = 0.0
var _sequential_index: int = 0
var _sequential_waiting := false
var _sequential_wait_elapsed: float = 0.0

## Per-target reversed item motion, set by [method restart_from_record] when
## replaying in reverse. A target with no entry here plays the group's
## ordinary forward [member AnimaGroupMotion.item_motion] instead — see
## [method _start_item].
var _reversed_item_motions: Dictionary = {}

## The recorded schedule for this execution, available once resolution has
## happened (the first [method advance] call) — `null` before that.
var execution_record: AnimaExecutionRecord = null

## Resolves the root this group actually resolves its target collection
## against: [member AnimaMotion.convenience_target] when this motion was
## built through [method Anima.grid] (alone or combined into a `.then()`/
## `.with()` composite with a different-target sibling), otherwise whatever
## root [param target] the enclosing [AnimaPlayback] supplies — the same
## per-leaf resolution [method AnimaPropertyMotionInstance._effective_target]
## applies for a leaf motion (`tech-spec.md` §Target-bound authoring contract,
## "`.play()` and per-leaf convenience targets").
func _effective_target(target: Node) -> Node:
	var convenience_target: Node = (motion as AnimaGroupMotion).convenience_target
	return convenience_target if convenience_target != null else target

## Advances every active item by [param delta]. [param target] is the root
## node that target-collection kinds like Children resolve against (or [member
## AnimaMotion.convenience_target] when set — see [method _effective_target]);
## resolution itself only happens once, on the first call. A composite
## combining leaves captured against different targets has no single root for
## [AnimaPlayback]'s own freed-target check to guard (§Lifecycle-safe playback
## policies) — this per-instance [method is_instance_valid] check is that same
## protection applied here too, mirroring [method
## AnimaPropertyMotionInstance.advance]'s own equivalent guard.
func advance(target: Node, delta: float) -> bool:
	target = _effective_target(target)
	# `null` is a legitimate target here (an EXPLICIT target collection needs
	# no root at all) — only a *freed* non-null reference is the failure case
	# this guard exists for; is_instance_valid(null) is false too, so it must
	# be excluded explicitly.
	if target != null and not is_instance_valid(target):
		return true
	if not _resolved:
		_resolve(target)
	if _cancelled or _items.is_empty():
		return true

	var group := motion as AnimaGroupMotion
	var scaled_delta := delta * group.speed
	if _uses_reduced_motion(target):
		return _advance_parallel(group, scaled_delta)
	match group.playback_mode:
		AnimaGroupMotion.PlaybackMode.PARALLEL:
			return _advance_parallel(group, scaled_delta)
		AnimaGroupMotion.PlaybackMode.SEQUENTIAL:
			return _advance_sequential(group, scaled_delta)
		_:
			return _advance_staggered(scaled_delta)

## Whether this group should collapse to parallel playback instead of its
## authored sequential/staggered mode — the same three-way resolution
## [method Anima.is_reduced_motion_active] applies for speed overrides,
## extended here to close the exact gap [constant
## AnimaBehaviour.ReducedMotion.SYSTEM]'s own doc comment named as missing
## ("until a system-preference adapter is introduced").
func _uses_reduced_motion(root: Node) -> bool:
	return Anima.is_reduced_motion_active(root)

## Restarts this playback from [param record] instead of resolving and
## scheduling again. Used by [method AnimaPlayback.reverse] so a reverse
## replays the exact recorded sequence rather than a fresh — and
## potentially different — resolution. [param reversed_item_motions] is the
## per-target map [method build_reversed_item_motions] produced from the run
## being reversed; a target missing from it plays the ordinary forward
## [member AnimaGroupMotion.item_motion] instead (it never started, so it has
## nothing of its own to reverse to).
func restart_from_record(record: AnimaExecutionRecord, reversed_item_motions: Dictionary = {}) -> void:
	execution_record = record
	_reversed_item_motions = reversed_item_motions
	_items.clear()
	for entry in record.entries:
		var item := _ItemState.new()
		item.target = entry.target
		item.start_offset = entry.start_offset
		item.index = _items.size()
		item.original_index = entry.original_index
		_items.append(item)

	_resolved = true
	_cancelled = false
	_elapsed = 0.0
	_sequential_index = 0
	_sequential_waiting = false
	_sequential_wait_elapsed = 0.0

## Builds a per-target map of each started item's own reversed motion (see
## [method AnimaMotionInstance.build_reversed]), for [method AnimaPlayback.reverse]
## to hand to a fresh [method restart_from_record] call so each item replays
## backward to what it actually started from, instead of repeating its
## original forward motion. A target that never started this run has no
## entry — there is nothing captured to reverse it to.
func build_reversed_item_motions() -> Dictionary:
	var reversed_by_target: Dictionary = {}
	for item in _items:
		if item.started and item.instance != null:
			var reversed_motion: AnimaMotion = item.instance.build_reversed()
			if reversed_motion != null:
				reversed_by_target[item.target] = reversed_motion
	return reversed_by_target

## Restores every started item's own captured initial value on its own
## resolved target — [param _target] is ignored, the same way [method advance]'s
## root only matters for resolution, which has already happened by the time
## anything has started.
func restore_initial(_target: Node) -> void:
	for item in _items:
		if item.started and item.instance != null:
			item.instance.restore_initial(item.target)

## Forces every resolved item to its own final state, regardless of [member
## AnimaGroupMotion.completion_policy] — completing the group visually means
## every item reaches its authored end state, not only the one item that
## would otherwise decide completion.
func force_complete(root: Node) -> void:
	if not _resolved:
		_resolve(root)
	if _cancelled:
		return

	var group := motion as AnimaGroupMotion
	for item in _items:
		if not is_instance_valid(item.target):
			continue
		if not item.started:
			_start_item(group, item)
		item.instance.force_complete(item.target)
		item.finished = true

func _resolve(root: Node) -> void:
	_resolved = true
	var group := motion as AnimaGroupMotion
	var resolution := AnimaTargetResolver.resolve(
		group.target_collection,
		root,
		[],
		group.invalid_target_policy,
		group.empty_group_policy,
	)
	if not resolution.can_play():
		_cancelled = true
		return

	var schedule := AnimaGroupScheduler.derive(group, resolution.targets)
	execution_record = AnimaExecutionRecord.from_schedule(schedule)
	for entry in schedule.entries:
		var item := _ItemState.new()
		item.target = entry.target
		item.start_offset = entry.start_offset
		item.index = _items.size()
		item.original_index = entry.original_index
		_items.append(item)

func _start_item(group: AnimaGroupMotion, item: _ItemState) -> void:
	item.started = true
	var item_motion: AnimaMotion = _reversed_item_motions.get(item.target, group.item_motion)
	item.instance = item_motion.create_runtime(_build_item_context(group, item))

## Builds the per-item [AnimaValueContext] an [AnimaValue] inside [param
## item]'s own motion resolves against: [member AnimaValueContext.target] is
## this item's own resolved node; [member AnimaValueContext.root] is the
## group's own container (this playback's own [member value_context], never
## another item) — the concrete "root means the group's container" decision
## (`tech-spec.md` §Dynamic values). Group-position fields read from [param
## item]'s own [member _ItemState.index]/[member _ItemState.original_index],
## already retained on the execution record — no separate per-item tracking
## is added (`project-rules.md` §Architecture).
func _build_item_context(group: AnimaGroupMotion, item: _ItemState) -> AnimaValueContext:
	var context := AnimaValueContext.new(item.target)
	context.root = value_context.target if value_context != null else item.target
	if value_context != null:
		context.context_data = value_context.context_data
	context.group_index = item.index
	context.group_count = _items.size()
	context.group_normalised_index = float(item.index) / float(maxi(_items.size() - 1, 1))
	var grid := group as AnimaGridMotion
	if grid != null and grid.grid_dimensions.x > 0:
		context.grid_row = item.original_index / grid.grid_dimensions.x
		context.grid_column = item.original_index % grid.grid_dimensions.x
	return context

## Advances one item, applying [member AnimaGroupMotion.invalid_target_policy]
## when its target has left the scene since it was resolved.
func _advance_item(group: AnimaGroupMotion, item: _ItemState, delta: float) -> void:
	if not is_instance_valid(item.target):
		item.finished = true
		if group.invalid_target_policy == AnimaGroupMotion.InvalidTargetPolicy.CANCEL_GROUP:
			_cancelled = true
		return
	item.finished = item.instance.advance(item.target, delta)

func _advance_parallel(group: AnimaGroupMotion, delta: float) -> bool:
	for item in _items:
		if not item.started:
			_start_item(group, item)
	for item in _items:
		if not item.finished:
			_advance_item(group, item, delta)
			if _cancelled:
				return true

	if group.completion_policy == AnimaGroupMotion.CompletionPolicy.FIRST_ITEM:
		for item in _items:
			if item.finished:
				return true
		return false

	for item in _items:
		if not item.finished:
			return false
	return true

func _advance_staggered(delta: float) -> bool:
	var group := motion as AnimaGroupMotion
	_elapsed += delta
	for item in _items:
		if item.finished:
			continue
		if not item.started:
			if _elapsed < item.start_offset:
				continue
			_start_item(group, item)
		_advance_item(group, item, delta)
		if _cancelled:
			return true

	for item in _items:
		if not item.finished:
			return false
	return true

## Advances items one at a time, in schedule order, waiting
## [member AnimaGroupMotion.sequential_gap] seconds after each one finishes
## before the next one starts.
func _advance_sequential(group: AnimaGroupMotion, delta: float) -> bool:
	if _sequential_index >= _items.size():
		return true

	if _sequential_waiting:
		_sequential_wait_elapsed += delta
		if _sequential_wait_elapsed < group.sequential_gap:
			return false
		_sequential_waiting = false
		_sequential_index += 1
		if _sequential_index >= _items.size():
			return true

	var item := _items[_sequential_index]
	if not item.started:
		_start_item(group, item)
	_advance_item(group, item, delta)
	if _cancelled:
		return true

	if item.finished and _sequential_index + 1 < _items.size():
		_sequential_waiting = true
		_sequential_wait_elapsed = 0.0
	elif item.finished:
		return true

	return false
