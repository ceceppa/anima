## Runtime instance for [_AnimaSequence] — advances each child per its
## scheduled start ([method _AnimaSequence.compute_schedule]) and completes
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

func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	super._init(p_motion, p_value_context)

	var sequence := motion as _AnimaSequence
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

## Children are scheduled by delay/delay_basis (_AnimaSequence.compute_schedule())
## rather than strictly starting one after another finishes, so more than one
## child can be active at once when a negative delay overlaps them.
##
## Fires each started child's own [member AnimaMotion.on_started_callback]/
## [member AnimaMotion.on_completed_callback] as it starts/finishes (phase-15)
## — a callback set on a child *before* it was folded into this composite
## (e.g. via [method AnimaMotion.then]) previously never fired, since only
## the root [AnimaPlayback] invoked the *composite's own* callbacks
## (`tech-spec.md` §Target-bound authoring contract).
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
			_call_if_valid(state.child.on_started_callback)

		var just_finished: bool = state.instance.advance(target, scaled_delta)
		if just_finished and not state.finished:
			state.finished = true
			_call_if_valid(state.child.on_completed_callback)

	for state in _states:
		if not state.finished:
			return false
	return true

## Restores every started child's own captured initial value (see [method
## AnimaMotionInstance.restore_initial]). A child that never started has
## nothing to restore.
func restore_initial(target: Node) -> void:
	for state in _states:
		if state.started:
			state.instance.restore_initial(target)

## Forces every child to its own final state, starting any that have not
## begun yet (so a sequence completes end-to-end, not just its started
## prefix) — see [method AnimaMotionInstance.force_complete]. Fires each
## newly-started/newly-finished child's own callbacks, same as [method advance].
func force_complete(target: Node) -> void:
	for state in _states:
		if not state.started:
			state.started = true
			state.instance = state.child.create_runtime()
			_call_if_valid(state.child.on_started_callback)
		state.instance.force_complete(target)
		if not state.finished:
			_call_if_valid(state.child.on_completed_callback)
		state.finished = true

## Builds a reversed [_AnimaSequence]: each started child's own reversed
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
	var reversed := _AnimaSequence.new()
	for state in started_states:
		var reversed_child: AnimaMotion = state.instance.build_reversed()
		if reversed_child != null:
			reversed.children.append(reversed_child)
	if reversed.children.is_empty():
		return null
	reversed.forward_speed = motion.forward_speed
	reversed.reverse_speed = motion.reverse_speed
	reversed.on_started_callback = motion.on_started_callback
	reversed.on_completed_callback = motion.on_completed_callback
	reversed.convenience_target = motion.convenience_target
	return reversed
