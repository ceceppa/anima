## Returned by [method Anima.on] — builds a canonical [AnimaPropertyMotion]
## for a common change to [member target] through a discoverable, named
## method instead of a raw property path. Every method below returns the
## same kind of resource [method Motion.to] would build; chaining a second
## semantic method (e.g. `.position().opacity()`) is not supported, because
## the first call already returns a motion, not this factory — combine
## motions explicitly with `then()`/`with()` instead
## (`tech-spec.md` §Convenience method interface).
class_name AnimaOnMotionFactory
extends RefCounted

## The node every semantic method below animates.
var target: Node

func _init(p_target: Node) -> void:
	target = p_target

## Animates [member target]'s position to [param to] — a [Vector2] for a
## [Control]/[Node2D] target, a [Vector3] for a [Node3D] target.
func position(to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _vector_leaf("position", "position", to, duration, false)

## Moves [member target] by [param delta] from wherever it actually is when
## playback starts, instead of to an absolute destination. Same typing as
## [method position].
func move_by(delta: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _vector_leaf("move_by", "position", delta, duration, true)

## Animates just the x component of [member target]'s position.
func position_x(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _axis_leaf("position_x", "position:x", to, duration, false, false)

## Animates just the y component of [member target]'s position.
func position_y(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _axis_leaf("position_y", "position:y", to, duration, false, false)

## Animates just the z component of [member target]'s position. [Node3D] targets only.
func position_z(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _axis_leaf("position_z", "position:z", to, duration, false, true)

## Animates [member target]'s scale to [param to]. Same typing as [method position].
func scale(to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _vector_leaf("scale", "scale", to, duration, false)

## Scales [member target] by [param delta] from its actual current scale.
## Same typing as [method position].
func scale_by(delta: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	return _vector_leaf("scale_by", "scale", delta, duration, true)

## Animates [member target]'s rotation (radians) to [param to]. [Control]/[Node2D]
## targets only — a [Node3D]'s rotation is three axes, not one value; use
## [method property] for 3D rotation.
func rotation(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _rotation_leaf("rotation", to, duration, false)

## Rotates [member target] by [param delta] radians from its actual current
## rotation. Same restriction as [method rotation].
func rotate_by(delta: float, duration: float = 0.0) -> AnimaPropertyMotion:
	return _rotation_leaf("rotate_by", delta, duration, true)

## Fades [member target]'s opacity ([code]modulate:a[/code]) to [param to].
## [CanvasItem] ([Control]/[Node2D]) targets only. A value outside `0.0..1.0`
## is allowed and produces an editor warning, never a clamp or a rejection.
func opacity(to: float, duration: float = 0.0) -> AnimaPropertyMotion:
	if target == null:
		return _fail("opacity", "a target — Anima.on(null) already reported this")
	if not (target is CanvasItem):
		return _fail("opacity", "a CanvasItem (Control or Node2D) target")
	if to < 0.0 or to > 1.0:
		push_warning("Anima.on(...).opacity(%s) is outside 0.0..1.0 — allowed, not clamped." % to)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("modulate:a")
	motion.to_value = to
	motion.duration = duration
	_stamp_origin(motion, "opacity")
	return motion

## Animates [member target]'s colour ([code]modulate[/code]) to [param to].
## [CanvasItem] ([Control]/[Node2D]) targets only. Spelled `.color()` to
## match Godot's own [Color] naming.
func color(to: Color, duration: float = 0.0) -> AnimaPropertyMotion:
	if target == null:
		return _fail("color", "a target — Anima.on(null) already reported this")
	if not (target is CanvasItem):
		return _fail("color", "a CanvasItem (Control or Node2D) target")

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("modulate")
	motion.to_value = to
	motion.duration = duration
	_stamp_origin(motion, "color")
	return motion

## Animates a [Control]'s size to [param to]. [Control] targets only. When
## the target's size or position is actually owned by a parent [Container]
## or by its own anchors, this produces an editor warning steering toward a
## Layout Transition instead — it does not block the motion.
func size(to: Vector2, duration: float = 0.0) -> AnimaPropertyMotion:
	if target == null:
		return _fail("size", "a target — Anima.on(null) already reported this")
	if not (target is Control):
		return _fail("size", "a Control target")

	_maybe_warn_layout_owned(target as Control, "size")

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("size")
	motion.to_value = to
	motion.duration = duration
	_stamp_origin(motion, "size")
	return motion

## Generic escape hatch for any other property. Delegates directly to
## [method Motion.to] — the same canonical resource direct authoring would
## build, with no target-class restriction of its own.
func property(path: NodePath, to: Variant, duration: float = 0.0) -> AnimaPropertyMotion:
	if path.is_empty():
		push_error("Anima.on(...).property() needs a non-empty NodePath.")
		return null

	var motion := Motion.to(path, to)
	motion.duration = duration
	_stamp_origin(motion, "property")
	return motion

func _vector_leaf(method_name: String, property_name: String, value: Variant, duration: float, relative: bool) -> AnimaPropertyMotion:
	if target == null:
		return _fail(method_name, "a target — Anima.on(null) already reported this")

	if target is Node3D:
		if not (value is Vector3):
			return _fail(method_name, "a Vector3 value for a Node3D target")
	elif target is Control or target is Node2D:
		if not (value is Vector2):
			return _fail(method_name, "a Vector2 value for a Control/Node2D target")
	else:
		return _fail(method_name, "a Control, Node2D, or Node3D target")

	if property_name == "position" and target is Control:
		_maybe_warn_layout_owned(target as Control, method_name)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property_name)
	motion.to_value = value
	motion.duration = duration
	motion.is_relative = relative
	_stamp_origin(motion, method_name)
	return motion

func _axis_leaf(method_name: String, property_path: String, value: float, duration: float, relative: bool, require_3d: bool) -> AnimaPropertyMotion:
	if target == null:
		return _fail(method_name, "a target — Anima.on(null) already reported this")
	if require_3d:
		if not (target is Node3D):
			return _fail(method_name, "a Node3D target")
	elif not (target is Control or target is Node2D or target is Node3D):
		return _fail(method_name, "a Control, Node2D, or Node3D target")

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property_path)
	motion.to_value = value
	motion.duration = duration
	motion.is_relative = relative
	_stamp_origin(motion, method_name)
	return motion

func _rotation_leaf(method_name: String, value: float, duration: float, relative: bool) -> AnimaPropertyMotion:
	if target == null:
		return _fail(method_name, "a target — Anima.on(null) already reported this")
	if not (target is Control or target is Node2D):
		return _fail(method_name, "a Control or Node2D target — a Node3D's rotation is three axes, use .property() instead")

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("rotation")
	motion.to_value = value
	motion.duration = duration
	motion.is_relative = relative
	_stamp_origin(motion, method_name)
	return motion

## Records which convenience method built [param motion] as editor-only,
## non-runtime-affecting metadata — read by the Motion Composer to show a
## semantic name instead of only the raw property path. Never consumed by
## playback, validation, or compilation.
func _stamp_origin(motion: AnimaPropertyMotion, method_name: String) -> void:
	motion.metadata["convenience_factory"] = "Anima.on()"
	motion.metadata["convenience_method"] = method_name

func _maybe_warn_layout_owned(control: Control, method_name: String) -> void:
	var container_owned := control.get_parent() is Container
	var anchor_owned := control.anchor_left != 0.0 or control.anchor_top != 0.0 \
		or control.anchor_right != 0.0 or control.anchor_bottom != 0.0
	if container_owned or anchor_owned:
		push_warning("Anima.on(...).%s() target's layout may recalculate this value — consider a Layout Transition instead." % method_name)

func _fail(method_name: String, expected: String) -> AnimaPropertyMotion:
	var got := target.get_class() if target != null else "null"
	push_error("Anima.on(...).%s() needs %s, got %s." % [method_name, expected, got])
	return null
