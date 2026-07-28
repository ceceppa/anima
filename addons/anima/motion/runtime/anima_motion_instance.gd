class_name AnimaMotionInstance
extends RefCounted

var motion: AnimaMotion

func _init(p_motion: AnimaMotion) -> void:
	motion = p_motion

## Advances playback by delta seconds and applies the motion's effect to target.
## Returns true once the motion has finished.
func advance(_target: Node, _delta: float) -> bool:
	push_error("AnimaMotionInstance.advance() must be overridden by a subtype")
	return true
