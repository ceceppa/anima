class_name AnimaConditional
extends AnimaMotion

enum ResolutionTiming {
	COMPILE_TIME,
	RUNTIME,
}

@export var when_true: AnimaMotion = null
@export var when_false: AnimaMotion = null
@export var condition: Callable = Callable()
@export var resolution_timing: ResolutionTiming = ResolutionTiming.RUNTIME

## COMPILE_TIME: resolves now and defers to the selected branch's own
## AnimaDuration. RUNTIME (default): reports Dynamic without evaluating
## `condition` — the branch isn't chosen until create_runtime() plays it.
func estimate_duration() -> AnimaDuration:
	if resolution_timing == ResolutionTiming.COMPILE_TIME:
		var branch := _select_branch()
		return branch.estimate_duration() if branch != null else AnimaDuration.fixed(0.0)
	return AnimaDuration.dynamic()

func _select_branch() -> AnimaMotion:
	if not condition.is_valid():
		return null
	return when_true if condition.call() else when_false

func create_runtime() -> Variant:
	return AnimaConditionalInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	if not condition.is_valid():
		errors.append("condition is required")
	if when_true == null:
		errors.append("when_true is required")
	else:
		errors.append_array(when_true.validate())
	if when_false == null:
		errors.append("when_false is required")
	else:
		errors.append_array(when_false.validate())
	return errors
