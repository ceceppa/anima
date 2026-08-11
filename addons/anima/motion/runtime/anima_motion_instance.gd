## Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]
## returns. [method advance] is the shared per-frame contract every subtype implements.
class_name AnimaMotionInstance
extends RefCounted

## The motion resource this instance is advancing.
var motion: AnimaMotion
## The per-resolution context an [AnimaValue]-typed field resolves against,
## supplied by [method AnimaMotion.create_runtime]. `null` for an instance
## built with no context — see [method _resolve_dynamic]'s fallback.
var value_context: AnimaValueContext = null

func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	motion = p_motion
	value_context = p_value_context

## Invokes [param callback] only when it is both [member Callable.is_valid]
## and — for a callable bound to an instance, including a lambda closure
## capturing `self` — that instance is still alive. [method Callable.is_valid]
## alone doesn't catch a freed closure target the same way it catches a freed
## bound-method target, which is what lets a leaked, never-cancelled
## [AnimaPlayback] crash calling a per-child callback (phase-15) against a
## node its own scene already freed. Shared by [AnimaSequenceInstance] and
## [AnimaParallelInstance] for each child's own `on_started`/`on_completed`.
func _call_if_valid(callback: Callable) -> void:
	if not callback.is_valid():
		return
	var bound_object: Object = callback.get_object()
	if bound_object != null and not is_instance_valid(bound_object):
		return
	callback.call()

## Resolves [param value] through [member value_context] when it is an
## [AnimaValue] — a fresh target-only context when none was supplied, the
## same "root defaults to the animated node" behaviour Anima v1 used for a
## plain, non-group motion — or returns [param value] unchanged for a literal.
func _resolve_dynamic(value: Variant, target: Node) -> Variant:
	if not (value is AnimaValue):
		return value
	var context: AnimaValueContext = value_context
	if context == null:
		context = AnimaValueContext.new(target)
	return (value as AnimaValue).resolve(context)

## Normalized (x, y) position of each [enum AnimaPivot.Kind] anchor
## within a target's own bounds — `(0, 0)` is the top-left corner, `(1, 1)`
## the bottom-right, matching Control.size / Sprite2D.texture-space. Shared
## by [method AnimaPropertyMotionInstance._apply_pivot] and [method
## AnimaKeyframeMotionInstance._resolve_and_apply_pivot] (`tech-spec.md`
## §Motion pivot control, "Shared with keyframe motions").
const _PIVOT_ANCHORS := {
	AnimaPivot.Kind.TOP_LEFT: Vector2(0.0, 0.0),
	AnimaPivot.Kind.TOP_CENTER: Vector2(0.5, 0.0),
	AnimaPivot.Kind.TOP_RIGHT: Vector2(1.0, 0.0),
	AnimaPivot.Kind.CENTER_LEFT: Vector2(0.0, 0.5),
	AnimaPivot.Kind.CENTER: Vector2(0.5, 0.5),
	AnimaPivot.Kind.CENTER_RIGHT: Vector2(1.0, 0.5),
	AnimaPivot.Kind.BOTTOM_LEFT: Vector2(0.0, 1.0),
	AnimaPivot.Kind.BOTTOM_CENTER: Vector2(0.5, 1.0),
	AnimaPivot.Kind.BOTTOM_RIGHT: Vector2(1.0, 1.0),
}

## Resolves and applies [param pivot] to [param target] once — the shared
## mechanism [AnimaPropertyMotionInstance] and [AnimaKeyframeMotionInstance]
## both call after their own gating (whether [param pivot] is [constant
## AnimaPivot.Kind.NONE] and whether the animated propert(y/ies)
## is/are `scale`/`rotation`) — see each caller and `tech-spec.md` §Motion
## pivot control. Only a [Control] (native `pivot_offset`) or a 2D node
## exposing both `offset` and `texture` (Sprite2D-like) are affected;
## anything else is left untouched.
func _apply_pivot_to(target: Node, pivot: AnimaPivot.Kind) -> void:
	var anchor: Vector2 = _PIVOT_ANCHORS.get(pivot, Vector2(0.5, 0.5))

	if target is Control:
		(target as Control).pivot_offset = anchor * (target as Control).size
	elif target is Node2D and _supports_offset_pivot(target):
		var texture: Texture2D = target.texture
		if texture == null:
			return
		var size: Vector2 = texture.get_size() * (target as Node2D).scale
		var delta: Vector2 = size * (Vector2(0.5, 0.5) - anchor)
		var basis_delta: Vector2 = (target as Node2D).global_transform.basis_xform(delta)
		target.offset += delta
		(target as Node2D).global_position -= basis_delta

## Whether [param target] exposes both `offset` and `texture` — the
## Sprite2D-like shape pivot uses to shift artwork instead of a native pivot.
func _supports_offset_pivot(target: Node) -> bool:
	var has_offset := false
	var has_texture := false
	for property in target.get_property_list():
		if property.name == "offset":
			has_offset = true
		elif property.name == "texture":
			has_texture = true
	return has_offset and has_texture

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
