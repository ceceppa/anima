## Runtime instance for [AnimaParallel] — advances every enabled child each
## frame and completes per its [member AnimaParallel.completion_policy].
class_name AnimaParallelInstance
extends AnimaMotionInstance

var _child_instances: Array = []
var _child_finished: Array[bool] = []
var _completion_index: int = -1

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

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
	reversed.on_started_callback = motion.on_started_callback
	reversed.on_completed_callback = motion.on_completed_callback
	return reversed
