## Returned by [method Anima.item] — builds a canonical [AnimaPropertyMotion]
## for a common per-item change, through the same named methods
## [AnimaOnMotionFactory] exposes. Unlike [method Anima.on], no target is
## known yet: an [AnimaGroupMotion] resolves and supplies each item's own
## target when it plays this motion as its [member AnimaGroupMotion.item_motion]
## — every resolved target gets its own runtime instance and its own
## captured start value, the same way any other item motion does
## (`tech-spec.md` §Target-bound authoring contract). Because no target is
## known at creation, these methods build unconditionally instead of
## validating a target class up front; an item whose resolved target can't
## use the motion falls back to [member AnimaGroupMotion.invalid_target_policy]
## like any other invalid group item.
class_name AnimaItemMotionFactory
extends RefCounted

## Animates each resolved item's position to [param to].
func position(to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("position", to, duration, false, "position")

## Moves each resolved item by [param delta] from wherever it actually is.
func move_by(delta: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("position", delta, duration, true, "move_by")

## Animates just the x component of each resolved item's position.
func position_x(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("position:x", to, duration, false, "position_x")

## Animates just the y component of each resolved item's position.
func position_y(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("position:y", to, duration, false, "position_y")

## Animates just the z component of each resolved item's position (3D items only).
func position_z(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("position:z", to, duration, false, "position_z")

## Animates each resolved item's scale to [param to].
func scale(to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("scale", to, duration, false, "scale")

## Scales each resolved item by [param delta] from its actual current scale.
func scale_by(delta: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("scale", delta, duration, true, "scale_by")

## Animates each resolved item's rotation (radians) to [param to].
func rotation(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("rotation", to, duration, false, "rotation")

## Rotates each resolved item by [param delta] radians from its actual current rotation.
func rotate_by(delta: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("rotation", delta, duration, true, "rotate_by")

## Fades each resolved item's opacity ([code]modulate:a[/code]) to [param to].
## A value outside `0.0..1.0` is allowed and produces an editor warning,
## never a clamp or a rejection.
func opacity(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	if to < 0.0 or to > 1.0:
		push_warning("Anima.item().opacity(%s) is outside 0.0..1.0 — allowed, not clamped." % to)
	return _leaf("modulate:a", to, duration, false, "opacity")

## Animates each resolved item's colour ([code]modulate[/code]) to [param to].
func color(to: Color, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("modulate", to, duration, false, "color")

## Animates each resolved item's size to [param to] (Control items only).
func size(to: Vector2, duration: float = 0.0) -> AnimaPropertyMotion:
	return _leaf("size", to, duration, false, "size")

## Generic escape hatch for any other property. Delegates directly to
## [method Motion.to] — the same canonical resource direct authoring would
## build.
func property(path: NodePath, to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	if path.is_empty():
		push_error("Anima.item().property() needs a non-empty NodePath.")
		return null

	var motion := Motion.to(path, to)
	motion.duration = duration
	_stamp_origin(motion, "property")
	return motion

func _leaf(property_path: String, value: Variant, duration: float, relative: bool, method_name: String) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property_path)
	motion.to_value = value
	motion.duration = duration
	motion.is_relative = relative
	_stamp_origin(motion, method_name)
	return motion

## Records which convenience method built [param motion] as editor-only,
## non-runtime-affecting metadata — see [method AnimaOnMotionFactory._stamp_origin].
func _stamp_origin(motion: AnimaPropertyMotion, method_name: String) -> void:
	motion.metadata["convenience_factory"] = "Anima.item()"
	motion.metadata["convenience_method"] = method_name
