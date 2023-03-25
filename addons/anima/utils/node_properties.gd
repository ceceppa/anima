#
# Different node types have different property names
#
# Example:
#   Control: position is "position"
#   Node2D : position is "offset"
#
# So, this utility class helps the animations to figure out which
# property to animate :)
#
class_name AnimaNodesProperties

static func get_position(node: Node):
	if node is Control or node is Window:
		return node.position
	elif node is Node2D:
		return node.global_position

	return node.global_transform.origin

static func get_size(node: Node) -> Vector2:
	if node is Control:
		node.get_size()
		return node.get_size()
	elif node is CanvasModulate:
		return Vector2.ZERO
	elif node is Node2D:
		return node.texture.get_size() * node.scale

	return Vector2.ZERO

static func get_scale(node: Node) -> Vector2:
	if node is Control:
		return node.scale
	
	return node.scale

static func get_rotation(node: Node):
	return node.rotation

static func set_2D_pivot(node: Node, pivot: int) -> void:
	var size: Vector2 = get_size(node)

	if node is Window:
		pass

	match pivot:
		ANIMA.PIVOT.TOP_CENTER:
			if node is Control:
				node.set_pivot_offset(Vector2(size.x / 2, 0))
			else:
				var position = node.global_position

				node.offset = Vector2(0, size.y / 2)
				node.global_position = position - node.offset
		ANIMA.PIVOT.TOP_LEFT:
			if node is Control:
				node.set_pivot_offset(Vector2(0, 0))
			else:
				var position = node.global_position

				node.offset = Vector2(size.x / 2, 0)
				node.global_position = position - node.offset
		ANIMA.PIVOT.CENTER:
			if node is Control:
				node.set_pivot_offset(size / 2)
		ANIMA.PIVOT.BOTTOM_CENTER:
			if node is Control:
				node.set_pivot_offset(Vector2(size.x / 2, size.y / 2))
			else:
				var position = node.global_position

				node.offset = Vector2(0, -size.y / 2)
				node.global_position = position - node.offset
		ANIMA.PIVOT.BOTTOM_LEFT:
			if node is Control:
				node.set_pivot_offset(Vector2(0, size.y))
			else:
				var position = node.global_position

				node.offset = Vector2(size.x / 2, size.y)
				node.global_position = position - node.offset
		ANIMA.PIVOT.BOTTOM_RIGHT:
			if node is Control:
				node.set_pivot_offset(Vector2(size.x, size.y / 2))
			else:
				var position = node.global_position

				node.offset = Vector2(-size.x / 2, size.y / 2)
				node.global_position = position - node.offset
		_:
			pass
#			printerr('Pivot point not handled yet')

static func get_property_value(node: Node, animation_data: Dictionary, property = null):
	if property == null:
		property = animation_data.property

	if property is Object:
		return property[animation_data.key]

	match property.to_lower():
		"x", "position:x":
			var position = get_position(node)

			return position.x
		"y", "position:y":
			var position = get_position(node)

			return position.y
		"z", "position:z":
			var position = get_position(node)

			return position.z
		"position":
			return get_position(node)
		"rotation","rotate":
			return get_rotation(node)
		"rotation:x", "rotate:x":
			return get_rotation(node).x
		"rotation:y", "rotate:y":
			if node is Control or node is Node2D:
				return get_rotation(node)

			return get_rotation(node).y
		"rotation:z", "rotate:z":
			return get_rotation(node).z
		"opacity":
			if node is MeshInstance3D:
				var material = node.get_surface_override_material(0)

				if material == null:
					return 0.0
				elif material is StandardMaterial3D:
					return material.albedo_color.a
				else:
					return material.get_shader_parameter("opacity")

			return node.modulate.a
		"skew":
			return Vector2(node.get_global_transform().y.x, node.get_global_transform().x.y)
		"skew:x":
			return node.get_global_transform().y.x
		"skew:y":
			return node.get_global_transform().x.y
		"size":
			return get_size(node)
		"size:x", "width":
			return get_size(node).x
		"size:y", "height":
			return get_size(node).y
		"text:visible_characters":
			var hack = UseTRFromStaticMethod.new()
			var translated_text = hack.get_position(node.text)

			return translated_text.replace(" ", "").length()
		"index":
			return node.get_index()

	var p = property.split(':')

	var property_name: String = p[0]
	var rect_property_name: String = 'rect_' + property_name
	var node_property_name: String

	var key = p[1] if p.size() > 1 else null
	var subkey = p[2] if p.size() > 2 else null

	if node.get(property_name):
		node_property_name = property_name
	elif node.get(rect_property_name) != null:
		node_property_name = rect_property_name
	elif property_name in node:
		node_property_name = property_name
	elif rect_property_name in node:
		node_property_name = rect_property_name

	if p[0] == 'shader_param':
		var material: ShaderMaterial
		if node is MeshInstance3D:
			material = node.get_surface_override_material(0)
		else:
			material = node.material

		return material.get_shader_parameter(p[1])

	if node_property_name:
		if subkey:
			return node[property_name][key][subkey]

		if key:
			var prop = node[node_property_name]

			if typeof(prop) == TYPE_RECT2:
				if ['x', 'y'].find(key) >= 0:
					return prop.position[key]

				if key == "w":
					return prop.size.x
				
				return prop.size.y

			if prop is String and key == "length":
				return prop.length()
			elif prop is Object and prop.has_method(key):
				prop.call(key)

			return prop[key]

		return node.get(node_property_name)

	if property.find('__') == 0:
		return 0

	return property_name

static func map_property_to_godot_property(node: Node, property: String) -> Dictionary:
	match property:
		"x", "position:x":
			if node is Control or node is Window:
				return {
					property = "position",
					key = "x",
				}

			return {
				property = "global_transform",
				key = "origin",
				subkey = "x"
			}
		"y", "position:y":
			if node is Control or node is Window:
				return {
					property = "position",
					key = "y",
				}

			return {
				property = "global_transform",
				key = "origin",
				subkey = "y"
			}
		"width":
			if node is Control or node is Window:
				return {
					property = "size",
					key = "x",
				}

			return {
				property = "size",
				key = "x",
			}
		"height":
			if node is Control or node is Window:
				return {
					property = "size",
					key = "y",
				}

			return {
				property = "size",
				key = "y",
			}
		"z", "position:z":
			if node is Control or node is Window:
				printerr('position:z is not supported by Control nodes')

			return {
				property = "global_transform",
				key = "origin",
				subkey = "z"
			}
		"position":
			if node is Control or node is Window:
				return {
					property = "position"
				}
			
			return {
				property = "global_transform",
				key = "origin"
			}
		"opacity":
			if node is MeshInstance3D:
				var material = node.get_surface_override_material(0)

				if material == null:
					return {}
				elif material is StandardMaterial3D:
					return {
						property = material,
						key = "albedo_color",
						subkey = "a"
					}

				return {
					callback = Callable(material, 'set_shader_parameter'),
					param = "opacity"
				}
			return {
				property = "modulate",
				key = "a"
			}
		"rotation", "rotate":
			return {
				property = "rotation"
			}
		"rotation:x", "rotate:x":
			return {
				property = "rotation",
				key = "x"
			}
		"rotation:y", "rotate:y":
			var property_name = "rotation"

			if node is Control or node is Node2D:
				return {
					property = "rotation"
				}

			return {
				property = "rotation",
				key = "y"
			}
		"rotation:z", "rotate:z":
			return {
				property = "rotation",
				key = "z"
			}
		"skew:x":
			if not node is Node2D:
				return {}

			return {
				property = "transform",
				key = "y",
				subkey = "x"
			}
		"skew:y":
			if not node is Node2D:
				return {}

			return {
				property = "transform",
				key = "x",
				subkey = "y"
			}
		"skew":
			return {
			}

	var p = property.split(':')

	var property_name: String = p[0]
	var rect_property_name: String = 'rect_' + property_name
	var node_property_name: String

	var key = p[1] if p.size() > 1 else null
	var subkey = p[2] if p.size() > 2 else null

	if node.get(property_name) or property_name in node:
		node_property_name = property_name
	elif node.get(rect_property_name) or rect_property_name in node:
		node_property_name = rect_property_name

	if p[0] == 'shader_param':
		var material: ShaderMaterial
		if node is MeshInstance3D:
			material = node.get_surface_override_material(0)
		else:
			material = node.material

		return {
			property = "shader_param",
			callback = Callable(material, 'set_shader_parameter'),
			param = p[1]
		}

	if node_property_name:
		var is_rect2 = (node_property_name in node and node[node_property_name] is Rect2)
		if is_rect2 and p.size() > 1:
			var k: String = p[1]

			if k == "x" or k == "y":
				key = "position"
				subkey = k
			else:
				key = "size"
				subkey = "x" if k == "w" else "y"

		if subkey:
			return {
				property = node_property_name,
				key = key,
				subkey = subkey,
				is_rect2 = false
			}

		if key:
			return {
				property = node_property_name,
				key = key,
				is_rect2 = is_rect2
			}

		return {
			property = node_property_name,
			is_rect2 = is_rect2
		}

	if property.find('__') == 0:
		return {
			property = property
		}

	return {
		property = property
	}

#
# Allow calling "tr" from a static function
#
class UseTRFromStaticMethod:
	func get_position(key) -> String:
		return tr(key)
