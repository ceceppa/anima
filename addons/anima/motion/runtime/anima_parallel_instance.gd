## Runtime instance for [AnimaParallel] — advances every enabled child each
## frame and completes per its [member AnimaParallel.completion_policy].
class_name AnimaParallelInstance
extends AnimaMotionInstance

class _ChildState:
	var child: AnimaMotion
	var instance: Variant = null
	var started: bool = false
	var finished: bool = false

var _states: Array[_ChildState] = []
var _elapsed: float = 0.0
var _completion_index: int = -1

## A child with [member AnimaMotion.delay] `<= 0.0` (the default) starts
## immediately here, firing its own [member AnimaMotion.on_started_callback]
## (phase-15) — a callback set on a child *before* it was folded into this
## composite (e.g. via [method AnimaMotion.with]) previously never fired,
## since only the root [AnimaPlayback] invoked the *composite's own*
## callbacks (`tech-spec.md` §Target-bound authoring contract). A child with
## a positive delay is deferred to [method advance] instead (phase-15) —
## [member AnimaMotion.delay] previously did nothing on a [AnimaParallel]
## child at all; see "Per-child delay inside .with()" in the same section.
func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	super._init(p_motion, p_value_context)

	var parallel := motion as AnimaParallel
	var completion_child := parallel.get_completion_child()

	for child in parallel.children:
		if not child.enabled:
			continue

		var state := _ChildState.new()
		state.child = child
		_states.append(state)

		if child == completion_child:
			_completion_index = _states.size() - 1

		if child.delay <= 0.0:
			state.started = true
			state.instance = child.create_runtime()
			_call_if_valid(child.on_started_callback)

## Advances every active child, then completes per completion_policy — all of
## them, or just the one tracked at [member _completion_index]. A child whose
## own [member AnimaMotion.delay] hasn't elapsed yet (relative to this
## parallel's own start — [member AnimaMotion.delay_basis] does not apply
## here, there being no "previous" child in an unordered group) doesn't start
## until it does. Fires each newly-started/newly-finished child's own
## callbacks — see [method _init] for the immediate-start case.
func advance(target: Node, delta: float) -> bool:
	if _states.is_empty():
		return true

	var scaled_delta := delta * motion.speed
	_elapsed += scaled_delta

	for state in _states:
		if state.finished:
			continue

		if not state.started:
			if _elapsed < state.child.delay:
				continue
			state.started = true
			state.instance = state.child.create_runtime()
			_call_if_valid(state.child.on_started_callback)

		var just_finished: bool = state.instance.advance(target, scaled_delta)
		if just_finished and not state.finished:
			state.finished = true
			_call_if_valid(state.child.on_completed_callback)

	if _completion_index >= 0:
		return _states[_completion_index].finished

	for state in _states:
		if not state.finished:
			return false
	return true

## Restores every started child's own captured initial value (see [method
## AnimaMotionInstance.restore_initial]) — safe even for a child that never
## captured one, since each subtype's own override guards that internally.
## A child that never started (still waiting on its own delay) has nothing
## to restore.
func restore_initial(target: Node) -> void:
	for state in _states:
		if state.started:
			state.instance.restore_initial(target)

## Forces every child to its own final state together — see [method
## AnimaMotionInstance.force_complete]. Applies to every child regardless of
## [member AnimaParallel.completion_policy], since completing the group
## visually means every animating property reaches its authored end state,
## not only the one tracked child that would otherwise decide completion.
## Starts any not-yet-started (still delayed) child first, then fires each
## newly-started/newly-finished child's own callbacks, same as [method advance].
func force_complete(target: Node) -> void:
	for state in _states:
		if not state.started:
			state.started = true
			state.instance = state.child.create_runtime()
			_call_if_valid(state.child.on_started_callback)
		state.instance.force_complete(target)
		if not state.finished:
			state.finished = true
			_call_if_valid(state.child.on_completed_callback)

## Builds a reversed [AnimaParallel]: every child that captured a start value
## gets its own reversed motion, still played together. `null` when no child
## has captured one yet.
func build_reversed() -> AnimaMotion:
	var reversed := AnimaParallel.new()
	for state in _states:
		if not state.started:
			continue
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
