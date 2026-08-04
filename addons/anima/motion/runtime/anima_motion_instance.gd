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

## Restores [param target] to the value captured when this instance began
## advancing, for [method AnimaPlayback.revert] and a
## [constant AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL] /
## [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL] outcome. A
## no-op by default — every subtype overrides this explicitly (see
## [AnimaPropertyMotionInstance], [AnimaSequenceInstance], [AnimaParallelInstance]).
func restore_initial(_target: Node) -> void:
	pass

## Forces this instance to its valid final state immediately, applying every
## active leaf's authored end value(s) — for [method AnimaPlayback.complete]
## and a [constant AnimaMotion.CancellationValuePolicy.COMPLETE] outcome. A
## no-op by default — every subtype overrides this explicitly.
func force_complete(_target: Node) -> void:
	pass
