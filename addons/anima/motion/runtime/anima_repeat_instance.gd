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
	if repeat.child != null and repeat.count > 0:
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
		return reversed.create_runtime()
	return repeat.child.create_runtime()

## Advances the current repetition; once it finishes, either waits out
## delay_between and starts the next repetition, or completes if that was the last one.
func advance(target: Node, delta: float) -> bool:
	var repeat := motion as AnimaRepeat
	if repeat.child == null or repeat.count <= 0:
		return true

	if _waiting_for_delay:
		_delay_elapsed += delta
		if _delay_elapsed < repeat.delay_between:
			return false
		_waiting_for_delay = false
		_iteration += 1
		_current_instance = _build_iteration_instance(_iteration)

	var child_finished: bool = _current_instance.advance(target, delta)
	if child_finished:
		if _iteration + 1 >= repeat.count:
			return true
		_waiting_for_delay = true
		_delay_elapsed = 0.0

	return false
