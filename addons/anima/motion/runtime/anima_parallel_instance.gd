## Runtime instance for [AnimaParallel] — advances every enabled child each
## frame and completes per its [member AnimaParallel.completion_policy].
class_name AnimaParallelInstance
extends AnimaMotionInstance

var _child_instances: Array = []
var _child_finished: Array[bool] = []
var _completion_index: int = -1

func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	super._init(p_motion, p_value_context)

	var parallel := motion as AnimaParallel
	var completion_child := parallel.get_completion_child()

	for child in parallel.children:
		if not child.enabled:
			continue

		_child_instances.append(child.create_runtime())
		_child_finished.append(false)

		if child == completion_child:
			_completion_index = _child_instances.size() - 1

## Advances every unfinished child, then completes per completion_policy —
## all of them, or just the one tracked at [member _completion_index].
func advance(target: Node, delta: float) -> bool:
	if _child_instances.is_empty():
		return true

	var scaled_delta := delta * motion.speed
	for i in range(_child_instances.size()):
		if not _child_finished[i]:
			_child_finished[i] = _child_instances[i].advance(target, scaled_delta)

	if _completion_index >= 0:
		return _child_finished[_completion_index]

	for finished in _child_finished:
		if not finished:
			return false
	return true

## Restores every child's own captured initial value (see [method
## AnimaMotionInstance.restore_initial]) — safe even for a child that never
## captured one, since each subtype's own override guards that internally.
func restore_initial(target: Node) -> void:
	for child_instance in _child_instances:
		child_instance.restore_initial(target)

## Forces every child to its own final state together — see [method
## AnimaMotionInstance.force_complete]. Applies to every child regardless of
## [member AnimaParallel.completion_policy], since completing the group
## visually means every animating property reaches its authored end state,
## not only the one tracked child that would otherwise decide completion.
func force_complete(target: Node) -> void:
	for child_instance in _child_instances:
		child_instance.force_complete(target)

## Builds a reversed [AnimaParallel]: every child that captured a start value
## gets its own reversed motion, still played together. `null` when no child
## has captured one yet.
func build_reversed() -> AnimaMotion:
	var reversed := AnimaParallel.new()
	for child_instance in _child_instances:
		var reversed_child: AnimaMotion = child_instance.build_reversed()
		if reversed_child != null:
			reversed.children.append(reversed_child)
	if reversed.children.is_empty():
		return null
	reversed.forward_speed = motion.forward_speed
	reversed.reverse_speed = motion.reverse_speed
	reversed.on_started_callback = motion.on_started_callback
	reversed.on_completed_callback = motion.on_completed_callback
	return reversed
