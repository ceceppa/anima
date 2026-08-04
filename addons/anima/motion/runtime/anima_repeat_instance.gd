## Runtime instance for [AnimaRepeat] — replays [member AnimaRepeat.child]
## [member AnimaRepeat.count] times, with an optional delay between repetitions.
class_name AnimaRepeatInstance
extends AnimaMotionInstance

var _iteration: int = 0
var _current_instance: Variant = null
var _waiting_for_delay: bool = false
var _delay_elapsed: float = 0.0

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)
	var repeat := motion as AnimaRepeat
	if repeat.child != null and repeat.count != 0:
		_current_instance = _build_iteration_instance(0)

## Odd iterations (0-indexed: 1, 3, 5, ...) reverse an AnimaPropertyMotion
## child's from/to values, per tech-spec.md's alternate rule. Any other
## child type always replays forward — reversing a composite is undefined.
func _build_iteration_instance(iteration: int) -> Variant:
	var repeat := motion as AnimaRepeat
	if repeat.alternate and iteration % 2 == 1 and repeat.child is AnimaPropertyMotion:
		var original := repeat.child as AnimaPropertyMotion
		var reversed := AnimaPropertyMotion.new()
		reversed.target_property = original.target_property
		reversed.from_value = original.to_value
		reversed.to_value = original.from_value
		reversed.duration = original.duration
		reversed.ease = original.ease
		reversed.speed = original.speed
		reversed.forward_speed = original.forward_speed
		reversed.reverse_speed = original.reverse_speed
		return reversed.create_runtime()
	return repeat.child.create_runtime()

## Advances the current repetition; once it finishes, either waits out
## delay_between and starts the next repetition, or completes if that was the
## last one. A negative [member AnimaRepeat.count] never completes on its own.
func advance(target: Node, delta: float) -> bool:
	var repeat := motion as AnimaRepeat
	if repeat.child == null or repeat.count == 0:
		return true

	var scaled_delta := delta * repeat.speed
	if _waiting_for_delay:
		_delay_elapsed += scaled_delta
		if _delay_elapsed < repeat.delay_between:
			return false
		_waiting_for_delay = false
		_iteration += 1
		_current_instance = _build_iteration_instance(_iteration)

	var child_finished: bool = _current_instance.advance(target, scaled_delta)
	if child_finished:
		if repeat.count > 0 and _iteration + 1 >= repeat.count:
			return true
		_waiting_for_delay = true
		_delay_elapsed = 0.0

	return false

## Restores the current iteration's own captured initial value — see [method
## AnimaMotionInstance.restore_initial].
func restore_initial(target: Node) -> void:
	if _current_instance != null:
		_current_instance.restore_initial(target)

## Forces the current iteration to its final state — a repeat's own notion of
## "complete" is the current iteration reaching its end, not exhausting
## [member AnimaRepeat.count] (which may be indefinite) — see [method
## AnimaMotionInstance.force_complete].
func force_complete(target: Node) -> void:
	if _current_instance != null:
		_current_instance.force_complete(target)

## Builds a reversed [AnimaRepeat]: the currently-active iteration's own
## reversed motion (see [method AnimaMotionInstance.build_reversed]), repeated
## the same [member AnimaRepeat.count] times with the same [member
## AnimaRepeat.delay_between] and [member AnimaRepeat.alternate] — the same
## "freshly built reversed motion, restart from the top" rule already applied
## to a leaf/[AnimaSequence]/[AnimaParallel] reversal, extended to [AnimaRepeat]
## instead of carved out as a special case. `null` before any iteration has
## captured a value yet.
func build_reversed() -> AnimaMotion:
	if _current_instance == null:
		return null

	var reversed_child: AnimaMotion = _current_instance.build_reversed()
	if reversed_child == null:
		return null

	var repeat := motion as AnimaRepeat
	var reversed := AnimaRepeat.new()
	reversed.child = reversed_child
	reversed.count = repeat.count
	reversed.delay_between = repeat.delay_between
	reversed.alternate = repeat.alternate
	reversed.forward_speed = repeat.forward_speed
	reversed.reverse_speed = repeat.reverse_speed
	reversed.on_started_callback = repeat.on_started_callback
	reversed.on_completed_callback = repeat.on_completed_callback
	return reversed
