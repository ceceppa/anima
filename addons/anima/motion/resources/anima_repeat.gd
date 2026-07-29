class_name AnimaRepeat
extends AnimaMotion

@export var child: AnimaMotion = null
@export var count: int = 1
@export var delay_between: float = 0.0
@export var alternate: bool = false

func estimate_duration() -> AnimaDuration:
	if child == null or count <= 0:
		return AnimaDuration.fixed(0.0)

	var child_duration := child.estimate_duration()
	if child_duration.kind != AnimaDuration.Kind.FIXED:
		return AnimaDuration.new(child_duration.kind, 0.0)

	var total: float = float(count) * child_duration.seconds + float(count - 1) * delay_between
	return AnimaDuration.fixed(total)

func create_runtime() -> Variant:
	return AnimaRepeatInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	if child == null:
		errors.append("child is required")
	else:
		errors.append_array(child.validate())
	return errors
