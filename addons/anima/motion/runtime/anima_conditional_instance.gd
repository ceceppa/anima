## Runtime instance for [_AnimaConditional] — selects a branch once at
## construction and advances only that branch's own runtime instance.
class_name AnimaConditionalInstance
extends AnimaMotionInstance

var _branch_instance: Variant = null

## Selects the branch exactly once, here at construction — never re-evaluates
## `condition` afterward, per tech-spec.md's "at most once per play" rule.
func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	super._init(p_motion, p_value_context)

	var conditional := motion as _AnimaConditional
	var branch: AnimaMotion = conditional._select_branch()
	if branch != null:
		_branch_instance = branch.create_runtime()

## Advances the branch selected at construction. Completes immediately if
## `condition` had no valid branch to select.
func advance(target: Node, delta: float) -> bool:
	if _branch_instance == null:
		return true
	return _branch_instance.advance(target, delta)

## Restores the selected branch's own captured initial value — see [method
## AnimaMotionInstance.restore_initial].
func restore_initial(target: Node) -> void:
	if _branch_instance != null:
		_branch_instance.restore_initial(target)

## Forces the selected branch to its final state — see [method
## AnimaMotionInstance.force_complete].
func force_complete(target: Node) -> void:
	if _branch_instance != null:
		_branch_instance.force_complete(target)
