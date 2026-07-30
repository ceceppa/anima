## Selects between [member when_true] and [member when_false] based on
## [member condition], evaluated once per [method create_runtime] call.
class_name AnimaConditional
extends AnimaMotion

## When [member condition] is evaluated.
enum ResolutionTiming {
	COMPILE_TIME,
	RUNTIME,
}

## Motion played when [member condition] returns `true`.
@export var when_true: AnimaMotion = null
## Motion played when [member condition] returns `false`.
@export var when_false: AnimaMotion = null
## Zero-argument [Callable] returning a [bool] that picks the branch.
@export var condition: Callable = Callable()
## When [member condition] is evaluated.
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

## Builds the runtime instance, selecting the branch once (see [method _select_branch]).
func create_runtime() -> Variant:
	return AnimaConditionalInstance.new(self)

## Requires [member condition], [member when_true], and [member when_false].
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
