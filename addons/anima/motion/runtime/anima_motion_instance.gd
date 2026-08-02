## Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]
## returns. [method advance] is the shared per-frame contract every subtype implements.
class_name AnimaMotionInstance
extends RefCounted

## The motion resource this instance is advancing.
var motion: AnimaMotion

func _init(p_motion: AnimaMotion) -> void:
	motion = p_motion

## Advances playback by delta seconds and applies the motion's effect to target.
## Returns true once the motion has finished.
func advance(_target: Node, _delta: float) -> bool:
	push_error("AnimaMotionInstance.advance() must be overridden by a subtype")
	return true

## Builds a new [AnimaMotion] that reverses this instance's actually resolved
## run, for [method AnimaPlayback.reverse] on a non-group motion. Returns
## `null` when this instance has not captured a start value yet (nothing to
## reverse to) or when this motion kind does not support the generic reverse
## path. Overridden by [AnimaPropertyMotionInstance], [AnimaSequenceInstance],
## and [AnimaParallelInstance].
func build_reversed() -> AnimaMotion:
	return null
