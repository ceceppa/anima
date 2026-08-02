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

var _items: Array[_ItemState] = []
var _resolved := false
var _cancelled := false
var _elapsed: float = 0.0
var _sequential_index: int = 0
var _sequential_waiting := false
var _sequential_wait_elapsed: float = 0.0

## The recorded schedule for this execution, available once resolution has
## happened (the first [method advance] call) — `null` before that.
var execution_record: AnimaExecutionRecord = null

## Advances every active item by [param delta]. [param target] is the root
## node that target-collection kinds like Children resolve against;
## resolution itself only happens once, on the first call.
func advance(target: Node, delta: float) -> bool:
	if not _resolved:
		_resolve(target)
	if _cancelled or _items.is_empty():
		return true

	var group := motion as AnimaGroupMotion
	if _uses_reduced_motion(target):
		return _advance_parallel(group, delta)
	match group.playback_mode:
		AnimaGroupMotion.PlaybackMode.PARALLEL:
			return _advance_parallel(group, delta)
		AnimaGroupMotion.PlaybackMode.SEQUENTIAL:
			return _advance_sequential(group, delta)
		_:
			return _advance_staggered(delta)

func _uses_reduced_motion(root: Node) -> bool:
	if root == null:
		return false
	var behaviour := Anima.get_behaviour(root)
	return behaviour != null and behaviour.reduced_motion == AnimaBehaviour.ReducedMotion.ENABLED

## Restarts this playback from [param record] instead of resolving and
## scheduling again. Used by [method AnimaPlayback.reverse] so a reverse
## replays the exact recorded sequence rather than a fresh — and
## potentially different — resolution.
func restart_from_record(record: AnimaExecutionRecord) -> void:
	execution_record = record
	_items.clear()
	for entry in record.entries:
		var item := _ItemState.new()
		item.target = entry.target
		item.start_offset = entry.start_offset
		_items.append(item)

	_resolved = true
	_cancelled = false
	_elapsed = 0.0
	_sequential_index = 0
	_sequential_waiting = false
	_sequential_wait_elapsed = 0.0

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
		_items.append(item)

func _start_item(group: AnimaGroupMotion, item: _ItemState) -> void:
	item.started = true
	item.instance = group.item_motion.create_runtime()

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
