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

func advance(target: Node, delta: float) -> bool:
	if _child_instances.is_empty():
		return true

	for i in range(_child_instances.size()):
		if not _child_finished[i]:
			_child_finished[i] = _child_instances[i].advance(target, delta)

	if _completion_index >= 0:
		return _child_finished[_completion_index]

	for finished in _child_finished:
		if not finished:
			return false
	return true
