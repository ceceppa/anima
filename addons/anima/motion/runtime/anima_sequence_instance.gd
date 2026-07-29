class_name AnimaSequenceInstance
extends AnimaMotionInstance

class _ChildState:
	var child: AnimaMotion
	var scheduled_start: float = 0.0
	var instance: Variant = null
	var started: bool = false
	var finished: bool = false

var _elapsed: float = 0.0
var _states: Array[_ChildState] = []

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

	var sequence := motion as AnimaSequence
	var enabled_children: Array[AnimaMotion] = []
	for child in sequence.children:
		if child.enabled:
			enabled_children.append(child)

	var starts := sequence.compute_schedule()
	for i in range(enabled_children.size()):
		var state := _ChildState.new()
		state.child = enabled_children[i]
		state.scheduled_start = starts[i]
		_states.append(state)

## Children are scheduled by delay/delay_basis (AnimaSequence.compute_schedule())
## rather than strictly starting one after another finishes, so more than one
## child can be active at once when a negative delay overlaps them.
func advance(target: Node, delta: float) -> bool:
	if _states.is_empty():
		return true

	_elapsed += delta

	for state in _states:
		if state.finished:
			continue

		if not state.started:
			if _elapsed < state.scheduled_start:
				continue
			state.started = true
			state.instance = state.child.create_runtime()

		state.finished = state.instance.advance(target, delta)

	for state in _states:
		if not state.finished:
			return false
	return true
