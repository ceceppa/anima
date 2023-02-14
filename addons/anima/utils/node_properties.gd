#
# Different node types have different property names
#
# Example:
#   Control: position is "rect_position"
#   Node2D : position is "offset"
#
# So, this utility class helps the animations to figure out which
# property to animate :)
#
class_name AnimaNodesProperties

static func get_position(node: Node) -> Vector2:
	if node is Control:
		return node.rect_position
	if node is Node2D:
		return node.position

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
		return node.rect_scale
	
	return node.scale

static func get_rotation(node: Node):
	if node is Control:
		return node.rect_rotation
	elif node is Node2D:
		return node.rotation_degrees

	return node.rotation

static func set_2D_pivot(node: Node, pivot: int) -> void:
	var size: Vector2 = get_size(node)

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

	match property:
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
			if node is MeshInstance:
				var material = node.get_surface_material(0)

				if material == null:
					return 0.0
				elif material is SpatialMaterial:
					return material.albedo_color.a
				else:
					return material.get_shader_param("opacity")

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
			var translated_text = hack.get_translation(node.text)

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
		if node is MeshInstance:
			material = node.get_surface_material(0)
		else:
			material = node.material

		return material.get_shader_param(p[1])

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
			if node is Control:
				return {
					property = "rect_position",
					key = "x",
				}
			elif node is Sprite:
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
			if node is Control:
				return {
					property = "rect_position",
					key = "y",
				}
			elif node is Sprite:
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
			if node is Control:
				return {
					property = "rect_size",
					key = "x",
				}

			return {
				property = "size",
				key = "x",
			}
		"height":
			if node is Control:
				return {
					property = "rect_size",
					key = "y",
				}

			return {
				property = "size",
				key = "y",
			}
		"z", "position:z":
			if node is Control:
				printerr('position:z is not supported by Control nodes')

			return {
				property = "global_transform",
				key = "origin",
				subkey = "z"
			}
		"position":
			if node is Control:
				return {
					property = "rect_position"
				}
			
			return {
				property = "global_transform",
				key = "origin"
			}
		"opacity":
			if node is MeshInstance:
				var material = node.get_surface_material(0)

				if material == null:
					return {}
				elif material is SpatialMaterial:
					return {
						property = material,
						key = "albedo_color",
						subkey = "a"
					}

				return {
					callback = funcref(material, 'set_shader_param'),
					param = "opacity"
				}
			return {
				property = "modulate",
				key = "a"
			}
		"rotation", "rotate":
			var property_name = "rotation"

			if node is Control:
				property_name = "rect_rotation"
			elif node is Node2D:
				property_name = "rotation_degrees"

			return {
				property = property_name
			}
		"rotation:x", "rotate:x":
			return {
				property = "rotation",
				key = "x"
			}
		"rotation:y", "rotate:y":
			var property_name = "rotation"

			if node is Control:
				return {
					property = "rect_rotation"
				}
			elif node is Node2D:
				return {
					property = "rotation_degrees"
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
		if node is MeshInstance:
			material = node.get_surface_material(0)
		else:
			material = node.material

		return {
			property = "shader_param",
			callback = funcref(material, 'set_shader_param'),
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

static func extract_shader_params(shader_code: String):
	var regex = RegEx.new()
	regex.compile("uniform\\s+(\\w+)\\s+(\\w+):?([^=]*).([^;]*)")

	var uniform_values: Array = regex.search_all(shader_code)
	var result := []

	for index in uniform_values.size():
		var rm: RegExMatch = uniform_values[index]
		var pieces: Array = rm.strings
		var type = _extract_type_from_shader_uniform(pieces[1].strip_edges())
		var default = _extract_value_from_shader_uniform(pieces[4].strip_edges())
		
		result.push_back({
			type = type,
			name = pieces[2],
			default = default
		})

	return result

static func _extract_type_from_shader_uniform(uniform_type: String) -> int:
	var type = TYPE_REAL

	match uniform_type:
		"float":
			type = TYPE_REAL
		"int":
			type = TYPE_INT
		"vec2":
			type = TYPE_VECTOR2
		"vec3":
			type = TYPE_VECTOR3
		"vec4":
			type = TYPE_COLOR

	return type

static func _extract_value_from_shader_uniform(shader_value: String):
	var regex = RegEx.new()
	
	regex.compile("\\((.*)\\)")

	var regex_result = regex.search_all(shader_value)
	var values_in_parenthesis: Array

	if regex_result.size() > 0:
		values_in_parenthesis = regex_result[0].strings[1].split(",")

	if shader_value.find("vec2") >= 0:
		if values_in_parenthesis.size() > 1:
			return Vector2(float(values_in_parenthesis[0]), float(values_in_parenthesis[1]))
		else:
			return Vector2(float(values_in_parenthesis[0]), float(values_in_parenthesis[0]))

	if shader_value.find("vec3") >= 0:
		if values_in_parenthesis.size() > 1:
			return Vector3(float(values_in_parenthesis[0]), float(values_in_parenthesis[1]), float(values_in_parenthesis[2]))
		else:
			return Vector3(float(values_in_parenthesis[0]), float(values_in_parenthesis[0]), float(values_in_parenthesis[0]))

	if shader_value.find("vec4") >= 0:
		if values_in_parenthesis.size() > 1:
			return Color(float(values_in_parenthesis[0]), float(values_in_parenthesis[1]), float(values_in_parenthesis[2]), float(values_in_parenthesis[3]))
		else:
			return Color(float(values_in_parenthesis[0]), float(values_in_parenthesis[0]), float(values_in_parenthesis[0]), float(values_in_parenthesis[0]))

	return float(shader_value)

#
# Allow calling "tr" from a static function
#
class UseTRFromStaticMethod:
	func get_translation(key) -> String:
		return tr(key)
