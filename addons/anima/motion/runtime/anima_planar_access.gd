## Reads and writes 2D-authored property values on a [Node3D], so a motion
## written for a Control or Node2D (every catalog preset) also plays on a 3D
## node. Used for an [AnimaKeyframeMotion] whose [member
## AnimaKeyframeMotion.planar] is `true`; for any other motion, or any
## non-[Node3D] target, [method read] and [method write] are a plain
## [method Object.get_indexed] / [method Object.set_indexed].
##
## The values land on the node's local XY plane, which faces a default
## [Camera3D] looking down -Z. Distances convert at [member pixels_per_metre],
## so a preset's pixel offsets and its [code]size[/code]-relative offsets
## keep the same proportions they have on a Control:
## [br]- [code]position[/code], [code]position:x[/code], [code]position:y[/code]:
## converted to metres; the y sign flips, because 2D's y axis points down and
## 3D's points up.
## [br]- [code]scale[/code] ([Vector2]): x and y as written; z follows x.
## [br]- [code]rotation[/code] (a single angle): rotation around Z, sign flipped
## for the same reason as y.
## [br]- [code]modulate:a[/code]: the node's own [code]modulate[/code] when it has
## one ([Label3D], [Sprite3D]); otherwise
## [member GeometryInstance3D.transparency] on the node and every geometry
## below it. A fully transparent geometry also stops casting shadows, which
## transparency alone doesn't do; its own shadow setting comes back as soon
## as it is visible again.
## [br]- [code]transform:x:y[/code], [code]transform:y:x[/code] (skew): shear of
## [member Node3D.basis], sign flipped.
## [br]- [code]size[/code], [code]size:x[/code], [code]size:y[/code]: read-only;
## the node's visual bounds in its own unscaled local space, converted to
## pixels. Writing them does nothing.
## [br]Anything else passes through unchanged.
class_name AnimaPlanarAccess
extends RefCounted

## How many 2D pixels one metre stands for. At the default, a 1 m cube moves
## like a 100 px card: [code]bounce[/code]'s 30 px hop lifts it 0.3 m.
static var pixels_per_metre: float = 100.0

## Returns [param path] on [param node], read as 2D when [param planar] is
## `true` and [param node] is a [Node3D].
static func read(node: Node, path: NodePath, planar: bool) -> Variant:
	if not planar or not (node is Node3D):
		return node.get_indexed(path)

	var spatial := node as Node3D
	match String(path):
		"position":
			return Vector2(spatial.position.x, -spatial.position.y) * pixels_per_metre
		"position:x":
			return spatial.position.x * pixels_per_metre
		"position:y":
			return -spatial.position.y * pixels_per_metre
		"scale":
			return Vector2(spatial.scale.x, spatial.scale.y)
		"rotation":
			return -spatial.rotation.z
		"modulate", "modulate:a":
			if "modulate" in spatial:
				return spatial.get_indexed(path)
			return _opacity(spatial) if String(path) == "modulate:a" else Color(1, 1, 1, _opacity(spatial))
		"transform:x:y":
			return -spatial.basis.x.y
		"transform:y:x":
			return -spatial.basis.y.x
		"size":
			return visual_size(spatial) * pixels_per_metre
		"size:x":
			return visual_size(spatial).x * pixels_per_metre
		"size:y":
			return visual_size(spatial).y * pixels_per_metre
	return node.get_indexed(path)

## Writes [param value] to [param path] on [param node], mapped from 2D when
## [param planar] is `true` and [param node] is a [Node3D].
static func write(node: Node, path: NodePath, value: Variant, planar: bool) -> void:
	if not planar or not (node is Node3D):
		node.set_indexed(path, value)
		return

	var spatial := node as Node3D
	match String(path):
		"position":
			if value is Vector2:
				spatial.position = Vector3(value.x, -value.y, spatial.position.z * pixels_per_metre) / pixels_per_metre
				return
		"position:x":
			spatial.position.x = float(value) / pixels_per_metre
			return
		"position:y":
			spatial.position.y = -float(value) / pixels_per_metre
			return
		"scale":
			if value is Vector2:
				spatial.scale = Vector3(value.x, value.y, value.x)
				return
		"rotation":
			if value is float or value is int:
				spatial.rotation.z = -float(value)
				return
		"modulate", "modulate:a":
			if "modulate" in spatial:
				spatial.set_indexed(path, value)
			else:
				_set_opacity(spatial, value.a if value is Color else float(value))
			return
		"transform:x:y":
			var basis := spatial.basis
			basis.x.y = -float(value)
			spatial.basis = basis
			return
		"transform:y:x":
			var basis := spatial.basis
			basis.y.x = -float(value)
			spatial.basis = basis
			return
		"size", "size:x", "size:y":
			return
	node.set_indexed(path, value)

## The XY size of every [VisualInstance3D] in [param node]'s subtree (itself
## included), measured in [param node]'s own unscaled local space — the 3D
## stand-in for [member Control.size]. [constant Vector2.ZERO] when the node
## has no visuals or isn't in the scene tree.
static func visual_size(node: Node3D) -> Vector2:
	if not node.is_inside_tree():
		return Vector2.ZERO
	var to_local := node.global_transform.affine_inverse()
	var bounds := AABB()
	var found := false
	for visual in _visuals(node):
		var box: AABB = (to_local * visual.global_transform) * visual.get_aabb()
		bounds = box if not found else bounds.merge(box)
		found = true
	return Vector2(bounds.size.x, bounds.size.y) if found else Vector2.ZERO

static func _visuals(node: Node) -> Array[VisualInstance3D]:
	var result: Array[VisualInstance3D] = []
	if node is VisualInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_visuals(child))
	return result

static func _geometries(node: Node) -> Array[GeometryInstance3D]:
	var result: Array[GeometryInstance3D] = []
	if node is GeometryInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_geometries(child))
	return result

static func _opacity(node: Node3D) -> float:
	var geometries := _geometries(node)
	return 1.0 if geometries.is_empty() else 1.0 - geometries[0].transparency

## Meta key holding a geometry's own [member GeometryInstance3D.cast_shadow]
## while [method _set_opacity] has turned its shadow off.
const _SAVED_SHADOW_META := &"_anima_planar_cast_shadow"

static func _set_opacity(node: Node3D, opacity: float) -> void:
	var invisible := opacity <= 0.001
	for geometry in _geometries(node):
		geometry.transparency = clampf(1.0 - opacity, 0.0, 1.0)
		if invisible and not geometry.has_meta(_SAVED_SHADOW_META):
			geometry.set_meta(_SAVED_SHADOW_META, geometry.cast_shadow)
			geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif not invisible and geometry.has_meta(_SAVED_SHADOW_META):
			geometry.cast_shadow = geometry.get_meta(_SAVED_SHADOW_META)
			geometry.remove_meta(_SAVED_SHADOW_META)
