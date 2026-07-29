class_name AnimaRaceInstance
extends AnimaMotionInstance

var _child_instances: Array = []
var _child_finished: Array[bool] = []

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

	var race := motion as AnimaRace
	for child in race.children:
		if not child.enabled:
			continue
		_child_instances.append(child.create_runtime())
		_child_finished.append(false)

## Completes as soon as any child finishes. Once this returns true, the
## caller stops calling advance() on this instance entirely — which is the
## "cancel" for every other child: they simply never advance again.
func advance(target: Node, delta: float) -> bool:
	if _child_instances.is_empty():
		return true

	for i in range(_child_instances.size()):
		if not _child_finished[i]:
			_child_finished[i] = _child_instances[i].advance(target, delta)

	for finished in _child_finished:
		if finished:
			return true
	return false
