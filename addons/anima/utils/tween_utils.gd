class_name AnimaTweenUtils

static func get_initial_and_relative_meta_keys(property: String) -> Dictionary:
	var property_name_for_meta = property.replace(":", "_")

	return {
		initial = "__anima_initial_relative_value_" + property_name_for_meta,
		relative = "__anima_last_relative_value_" + property_name_for_meta,
	}

static func calculate_from_and_to(animation_data: Dictionary) -> Dictionary:
	var node: Node = animation_data.node
	var from
	var to
	var relative = animation_data.relative if animation_data.has('relative') else false
	var current_value = AnimaNodesProperties.get_property_value(node, animation_data)

	if animation_data.has("from") and animation_data.from == null:
		animation_data.erase('from')

	if animation_data.has("to") and animation_data.to == null:
		animation_data.erase('to')

	#
	# Godot4 doesn't like a meta_keys.initial containing the symbol :
	#
	var meta_keys = get_initial_and_relative_meta_keys(animation_data.property)

	var calculated_from = null
	
	if animation_data.has("from"):
		calculated_from = calculate_dynamic_value(animation_data.from, animation_data)

	from = current_value

	if relative:
		if not node.has_meta(meta_keys.relative):
			node.set_meta(meta_keys.initial, current_value)

			if calculated_from:
				from += calculated_from
		else:
			var previous_end_position = node.get_meta(meta_keys.relative)

			from = previous_end_position

	elif calculated_from != null:
		from = calculated_from

	if animation_data.has('to'):
		var start = from

		#
		# Translations created via keyframes behave slighly different from
		# using `anima_position_relative`.
		# Because keyframes-translations are relative to the node initial position,
		# while anima_position_relative are relative to the previous "position"
		#
		if relative and animation_data.has("_is_translation") and node.has_meta(meta_keys.initial):
			start = node.get_meta(meta_keys.initial)

		to = calculate_dynamic_value(animation_data.to, animation_data)
		to = _maybe_calculate_relative_value(relative, to, start)
	else:
		to = current_value

	if relative:
		node.set_meta(meta_keys.relative, to)

	var pivot = animation_data.pivot if animation_data.has("pivot") else ANIMA.PIVOT.CENTER
	if not node is Node3D and not node is CanvasModulate:
		AnimaNodesProperties.set_2D_pivot(animation_data.node, pivot)

	if from is Vector2 and to is Vector3:
		to = Vector2(to.x, to.y)

	if animation_data.has("__debug"):
		print("calculate_from_and_to")
		printt("", "Node Name:", animation_data.node.name, "property", animation_data.property, "from", from, "to", to, "current_value", current_value)
		printt("", animation_data)

	if typeof(to) == TYPE_RECT2:
		return {
			from = from,
			diff = { position = to.position - from.position, size = to.size - from.size }
		}

	return {
		from = from,
		diff = to - from
	}

static func calculate_dynamic_value(value, animation_data: Dictionary):
	var should_ignore = (not value is String and not value is Array) or (value is String and value.find(':') < 0)
	if should_ignore:
		return value

	var values_to_check: Array

	if value is String:
		values_to_check.push_back(value)
	else:
		values_to_check = value

	var DYNAMIC_EXTRACTOR_REGEX := RegEx.new()
	DYNAMIC_EXTRACTOR_REGEX.compile("(@?[\\.:\\/]*[a-zA-Z_]*:[a-z]*:?[^\\s\\)]+)")

	var all_results := []
	var root = animation_data.node

	if animation_data.has("_root_node"):
		root = animation_data._root_node

	for single_formula in values_to_check:
		if single_formula == "":
			single_formula = "0.0"

		var results := DYNAMIC_EXTRACTOR_REGEX.search_all(single_formula)
		var variables := []
		var values := []

		results.reverse()

		for index in results.size():
			var rm: RegExMatch = results[index]
			var regex_result = rm.get_string()
			var info: Array = regex_result.split(":")
			var source = info.pop_front()
			var source_node: Node
			var property: String = ":".join(PackedStringArray(info))

			if source == '' or source == '.':
				source_node = animation_data.node
			elif source[0] == '@':
				source_node = animation_data.node
				property = regex_result
			else:
				source_node = root.get_node(source)

			if source_node == null:
				printerr("Node not found: ", source, info)

				return value

			var property_value = AnimaNodesProperties.get_property_value(source_node, animation_data, property)
			var variable := char(65 + index)

			variables.push_back(variable)
			values.push_back(property_value)

			single_formula = "%s%s%s" % [single_formula.substr(0, rm.get_start()), variable, single_formula.substr(rm.get_end())]

		var expression := Expression.new()
		expression.parse(single_formula, variables)

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
