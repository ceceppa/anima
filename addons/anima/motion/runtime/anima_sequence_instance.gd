## Runtime instance for [AnimaSequence] — advances each child per its
## scheduled start ([method AnimaSequence.compute_schedule]) and completes
## once every enabled child has finished.
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

	var scaled_delta := delta * motion.speed
	_elapsed += scaled_delta

	for state in _states:
		if state.finished:
			continue

		if not state.started:
			if _elapsed < state.scheduled_start:
				continue
			state.started = true
			state.instance = state.child.create_runtime()

		state.finished = state.instance.advance(target, scaled_delta)

	for state in _states:
		if not state.finished:
			return false
	return true

## Builds a reversed [AnimaSequence]: each started child's own reversed
## motion, in reverse start order, keeping each child's own delay/delay_basis.
## `null` when no child has started yet.
func build_reversed() -> AnimaMotion:
	var started_states: Array[_ChildState] = []
	for state in _states:
		if state.started:
			started_states.append(state)
	if started_states.is_empty():
		return null

	started_states.reverse()
	var reversed := AnimaSequence.new()
	for state in started_states:
		var reversed_child: AnimaMotion = state.instance.build_reversed()
		if reversed_child != null:
			reversed.children.append(reversed_child)
	if reversed.children.is_empty():
		return null
	reversed.on_started_callback = motion.on_started_callback
	reversed.on_completed_callback = motion.on_completed_callback
	return reversed
