## Runtime instance for [AnimaRace] — advances every enabled child each frame
## and completes as soon as the fastest one finishes.
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

## Restores every child's own captured initial value — see [method
## AnimaMotionInstance.restore_initial].
func restore_initial(target: Node) -> void:
	for child_instance in _child_instances:
		child_instance.restore_initial(target)

## Forces the first child to its final state — a race's own notion of
## "complete" is having a winner, so completing early declares the first
## child the winner and force-completes only it, leaving the rest untouched
## the same way a natural race finish does. See [method
## AnimaMotionInstance.force_complete].
func force_complete(target: Node) -> void:
	if _child_instances.is_empty():
		return
	_child_instances[0].force_complete(target)
	_child_finished[0] = true
