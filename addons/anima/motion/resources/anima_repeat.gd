## Repeats [member child] [member count] times, with an optional delay between
## repeats and an alternating (ping-pong) mode.
class_name AnimaRepeat
extends AnimaMotion

## The motion to repeat.
@export var child: AnimaMotion = null
## How many times [member child] plays. Always finite this phase.
@export var count: int = 1
## Delay in seconds between one repetition ending and the next starting.
@export var delay_between: float = 0.0
## When `true`, odd repetitions reverse [member child] (swap `from_value`/
## `to_value` for an [AnimaPropertyMotion] child) instead of repeating it
## identically.
@export var alternate: bool = false

## Sums [member child]'s duration across every repetition plus the delays
## between them, once [member child] itself reports a fixed duration.
func estimate_duration() -> AnimaDuration:
	if child == null or count <= 0:
		return AnimaDuration.fixed(0.0)

	var child_duration := child.estimate_duration()
	if child_duration.kind != AnimaDuration.Kind.FIXED:
		return AnimaDuration.new(child_duration.kind, 0.0)

	var total: float = float(count) * child_duration.seconds + float(count - 1) * delay_between
	return AnimaDuration.fixed(total)

## Builds the runtime instance that replays [member child].
func create_runtime() -> Variant:
	return AnimaRepeatInstance.new(self)

## Requires [member child].
func validate() -> Array[String]:
	var errors: Array[String] = []
	if child == null:
		errors.append("child is required")
	else:
		errors.append_array(child.validate())
	return errors
