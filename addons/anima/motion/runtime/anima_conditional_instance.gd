class_name AnimaConditionalInstance
extends AnimaMotionInstance

var _branch_instance: Variant = null

## Selects the branch exactly once, here at construction — never re-evaluates
## `condition` afterward, per tech-spec.md's "at most once per play" rule.
func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

	var conditional := motion as AnimaConditional
	var branch: AnimaMotion = conditional._select_branch()
	if branch != null:
		_branch_instance = branch.create_runtime()

func advance(target: Node, delta: float) -> bool:
	if _branch_instance == null:
		return true
	return _branch_instance.advance(target, delta)
