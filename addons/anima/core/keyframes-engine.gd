extends Node
class_name AnimaKeyframesEngine


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
static func flatten_keyframes_data(data: Dictionary) -> Array:
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

			var is_valid_key = typeof(percentage) == TYPE_INT or typeof(percentage) == TYPE_FLOAT

			if not is_valid_key:
				continue

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

	if frame_keys[0] != 0:
		frame_keys.push_front(0)
		result[0] = {}

	var output := []
	var keys_to_insert := {}

	var keys_to_ignore = ["easing", "pivot"]
	for index in range(1, frame_keys.size()):
		var frame_key = frame_keys[index]

		for key in result[frame_key]:
			if keys_to_ignore.find(key) < 0 and not result[0].has(key):
				var is_relative_property: bool = key.begins_with("+")

				if is_relative_property and result[0].has(key.substr(1)):
					continue

				if not keys_to_insert.has(key):
					keys_to_insert[key] = 0

				if not is_relative_property:
					keys_to_insert[key] += 1
				else:
					keys_to_insert[key] = 1

	for frame_key in frame_keys:
		var frame_data = result[frame_key]

		if frame_data.has("skew"):
			frame_data["skew:x"] = frame_data.skew.x / 32.0
			frame_data["skew:y"] = frame_data.skew.y / 32.0

			frame_data.erase("skew")

		output.push_back({ percentage = frame_key, data = frame_data })

	for key in keys_to_insert:
		if keys_to_insert[key] == 1:
			output[0].data[key] = null

	return output

#
# Given an CSS-Keyframe like Dictionary of frames generates the animation frames
#
#	0: {
#		opacity = 0,
#		scale = Vector2(0.3, 0.3),
#		y = 100,
#		easing = [0.55, 0.055, 0.675, 0.19],
#	},
#	60: {
#		opacity = 1,
#		scale = Vector2(0.475, 0.475),
#		y = 100,
#		easing = [0.55, 0.055, 0.675, 0.19]
#	},
#	100: {
#		scale = Vector2(1, 1),
#		y = 0
#	}
#
static func parse_frames(animation_data: Dictionary, keyframes_data: Dictionary) -> Array:
	var all_frames = flatten_keyframes_data(keyframes_data)
	var duration = animation_data.duration
	var output := []
	
	var initial_values = keyframes_data.initial_values if keyframes_data.has("initial_values") else {}
	var initial_values_applied := {}

	if all_frames.size() == 1:
		printerr("Invalid frame animation!")

		return output

	var all_frames_size = all_frames.size()
	var reserved_properties = ["easing", "pivot"]
	var deferred_initial_values := {}

	if keyframes_data.has("_duration"):
		duration = AnimaTweenUtils.calculate_dynamic_value(
			keyframes_data._duration.replace("{duration}", str(duration)),
			animation_data
		)

	for index in all_frames.size() - 1:
		var current_frame_data = all_frames[index]

		for property_name in current_frame_data.data:
			var property: String = property_name
			var frame_data = animation_data.duplicate()

			if property.begins_with("+"):
				property = property.substr(1)
				frame_data.relative = true

			if reserved_properties.find(property) >= 0:
				continue

			var relative_property_name = "+" + property if not property.begins_with("+") else property
			var next_frame_data = _find_next_value(all_frames.slice(index + 1, all_frames_size), property, relative_property_name)
			var to_value = null
			
			if next_frame_data != null:
				to_value = next_frame_data.data[property] if next_frame_data.data.has(property) else next_frame_data.data[relative_property_name]

			if next_frame_data and next_frame_data.data.has(relative_property_name):
				frame_data.relative = true

			var from_value = current_frame_data.data[property] if current_frame_data.has(property) else current_frame_data.data[property_name]

			if next_frame_data == null or (typeof(to_value) == typeof(from_value) and to_value == from_value):
				if current_frame_data.percentage == 0:
					deferred_initial_values[property] = from_value

				continue

			var percentage = (next_frame_data.percentage - current_frame_data.percentage) / 100.0
			var frame_duration = max(ANIMA.MINIMUM_DURATION, duration * percentage)
			var wait_time: float = (current_frame_data.percentage / 100.0) * duration

			if animation_data.has("_wait_time"):
				wait_time += animation_data._wait_time

			var easing = _get_reserved_property_value(current_frame_data, next_frame_data, "easing")
			var pivot = _get_reserved_property_value(current_frame_data, next_frame_data, "pivot")

			if keyframes_data.has("easing"):
				frame_data.easing = keyframes_data.easing
			if keyframes_data.has("pivot"):
				frame_data.pivot = keyframes_data.pivot

			if easing:
				frame_data.easing = easing
			if pivot:
				frame_data.pivot = pivot

			if initial_values.has(property) and not initial_values_applied.has(property):
				frame_data.initial_value = initial_values[property]

				initial_values_applied[property] = 1

			if property.find("translate") >= 0:
				property = property.replace("translate", "position")
				frame_data._is_translation = true
				frame_data.relative = true

			var property_value = AnimaNodesProperties.get_property_value(animation_data.node, animation_data, property)
			var property_type = typeof(property_value)

			if property_type != typeof(from_value) and typeof(from_value) == TYPE_VECTOR3:
				from_value = Vector2(from_value.x, from_value.y)

			if property_type != typeof(to_value) and typeof(to_value) == TYPE_VECTOR3:
				to_value = Vector2(to_value.x, to_value.y)

			var current_value = AnimaNodesProperties.get_property_value(animation_data.node, animation_data, property)
			if not frame_data.has("relative") and \
				deferred_initial_values.has(property) and \
				not initial_values_applied.has(property):
				if from_value != null and from_value != current_value:
					frame_data.initial_value = from_value

					initial_values_applied[property] = 1

				deferred_initial_values.erase(property)

			frame_data.duration = frame_duration
			frame_data.property = property
			frame_data.from = from_value
			frame_data.to = to_value
			frame_data._wait_time = wait_time

			output.push_back(frame_data)

	return output

static func _get_reserved_property_value(current: Dictionary, next: Dictionary, key: String):
	if current.data.has(key):
		return current.data[key]
	elif next.data.has(key):
		return next.data[key]

	return null

static func _find_next_value(remaining_frames_data: Array, property: String, relative_property_name: String):
	for data in remaining_frames_data:
		if data.data.has(property) or data.data.has(relative_property_name):
			return data

	return null
