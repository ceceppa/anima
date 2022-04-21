class_name AnimaTweenUtils

static func calculate_from_and_to(animation_data: Dictionary, is_backwards_animation: bool) -> Dictionary:
	var node: Node = animation_data.node
	var from
	var to
	var relative = animation_data.relative if animation_data.has('relative') else false
	var current_value = AnimaNodesProperties.get_property_value(node, animation_data)

	if animation_data.has("from") and animation_data.from == null:
		animation_data.erase('from')

	if animation_data.has("to") and animation_data.to == null:
		animation_data.erase('to')

	if animation_data.has('from'):
		from = maybe_calculate_value(animation_data.from, animation_data)
		from = _maybe_convert_from_deg_to_rad(node, animation_data, from)
	else:
		from = current_value

	if animation_data.has('to'):
		var start = current_value if is_backwards_animation else from

		to = maybe_calculate_value(animation_data.to, animation_data)
		to = _maybe_convert_from_deg_to_rad(node, animation_data, to)
		to = _maybe_calculate_relative_value(relative, to, start)
	else:
		to = current_value

	var pivot = animation_data.pivot if animation_data.has("pivot") else Anima.PIVOT.CENTER
	if not node is Spatial:
		AnimaNodesProperties.set_2D_pivot(animation_data.node, pivot)

	var s = -1.0 if is_backwards_animation and relative else 1.0

	if from is Vector2 and to is Vector3:
		to = Vector2(to.x, to.y)

	if animation_data.has("__debug"):
		print("")
		printt("Node Name:", animation_data.node.name, "property", animation_data.property, "from", from, "to", to, "current_value", current_value)
		printt("", animation_data)

	if typeof(to) == TYPE_RECT2:
		return {
			from = from,
			diff = { position = to.position - from.position, size = to.size - from.size }
		}

	return {
		from = from,
		diff = (to - from) * s
	}

static func maybe_calculate_value(value, animation_data: Dictionary):
	if (not value is String and not value is Array) or (value is String and value.find(':') < 0):
		return value

	var values_to_check: Array

	if value is String:
		values_to_check.push_back(value)
	else:
		values_to_check = value

	var regex := RegEx.new()
	regex.compile("([\\w\\/.:]+[a-zA-Z]*:[a-z]*:?[a-z_]*)")

	var all_results := []
	var root = animation_data.node

	if animation_data.has("_root_node"):
		root = animation_data._root_node

	for single_value in values_to_check:
		if single_value == "":
			single_value = "0.0"

		var results := regex.search_all(single_value)
		var variables := []
		var values := []

		results.invert()

		for index in results.size():
			var rm: RegExMatch = results[index]
			var info: Array = rm.get_string().split(":")
			var source = info.pop_front()
			var source_node: Node

			if source == '' or source == '.':
				source_node = animation_data.node
			else:
				source_node = root.get_node(source)

			if source_node == null:
				printerr("Node not found: ", source)

				return value

			var property: String = PoolStringArray(info).join(":")

			var property_value = AnimaNodesProperties.get_property_value(source_node, animation_data, property)

			var variable := char(65 + index)

			variables.push_back(variable)
			values.push_back(property_value)

			single_value.erase(rm.get_start(), rm.get_end() - rm.get_start())
			single_value = single_value.insert(rm.get_start(), variable)

		var expression := Expression.new()
		expression.parse(single_value, variables)

		var result = expression.execute(values)

		all_results.push_back(result)

	if value is String:
		return all_results[0]

	if all_results.size() == 2:
		return Vector2(all_results[0], all_results[1])
	elif all_results.size() == 3:
		return Vector3(all_results[0], all_results[1], all_results[2])
	elif all_results.size() == 4:
		return Rect2(all_results[0], all_results[1], all_results[2], all_results[3])

	return all_results

static func _maybe_calculate_relative_value(relative, value, current_node_value):
	if not relative:
		return value

	if value is Rect2:
		value.position += current_node_value.position
		value.size += current_node_value.size

		return value

	if current_node_value is Vector2 and value is Vector3:
		value.x += current_node_value.x
		value.y += current_node_value.y

		return value

	return value + current_node_value

static func _maybe_convert_from_deg_to_rad(node: Node, animation_data: Dictionary, value):
	if animation_data.property is Object or animation_data.property.find('rotation') < 0:
		return value

	if value is Vector3:
		return Vector3(deg2rad(value.x), deg2rad(value.y), deg2rad(value.z))

	return deg2rad(value)

#
# Flattens a possible key of percentages, example:
#
#  [0, 10, 20] => {...}
#
# becomes
#
# 0: {...},
# 10: {...},
# 20: {...},
#
# also replaces "from" with "0" and "to" with "100"
#
static func flatten_keyframes_data(data: Dictionary) -> Dictionary:
	var result := {}

	for key in data:
		var is_dictionary = data.has(key) and data[key] is Dictionary
		var value: Dictionary = data[key].duplicate() if is_dictionary else {}

		if not key is Array:
			key = [key]

		for percentage in key:
			if percentage is String:
				if percentage == "from":
					percentage = 0
				elif percentage == "to":
					percentage = 100

			if not result.has(percentage):
				result[percentage] = {}

			for k in value:
				result[percentage][k] = value[k]

	var frame_keys := []
	
	for key in result.keys():
		if key is String:
			continue

		frame_keys.push_back(key)

	frame_keys.sort()

	# The 1st frame must have all the key set. If not the current value will be "forced"
	var keys_to_insert := {}
	for index in range(1, frame_keys.size()):
		var frame_key = frame_keys[index]

		for key in result[frame_key]:
			if key != "easing" and not result[frame_keys[0]].has(key) and not keys_to_insert.has(key):
				keys_to_insert[key] = "__current_value__"
				result[frame_keys[0]][key] = null

	return result
