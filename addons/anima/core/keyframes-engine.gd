extends Node
class_name AnimaKeyframesEngine

var _frame_key_checker = RegEx.new()
var _add_initial_values: FuncRef
var _add_animation_data: FuncRef

func _init(_add_initial_values_callback: FuncRef, add_animtion_data_callback: FuncRef):
	_frame_key_checker.compile("\\d")

	_add_initial_values = _add_initial_values_callback
	_add_animation_data = add_animtion_data_callback

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
func add_frames(animation_data: Dictionary, full_keyframes_data: Dictionary, meta_data_prefix: String) -> float:
	var last_duration := 0.0
	var relative_properties: Array = ["x", "y", "z", "position", "position:x", "position:z", "position:y"]
	var pivot = full_keyframes_data.pivot if full_keyframes_data.has("pivot") else null
	var easing = full_keyframes_data.easing if full_keyframes_data.has("easing") else null

	if animation_data.has("_ignore_relative") and animation_data._ignore_relative:
		relative_properties = []

	if full_keyframes_data.has("relative"):
		relative_properties = full_keyframes_data.relative

	animation_data._relative_to = ANIMA.RELATIVE_TO.INITIAL_VALUE

	if full_keyframes_data.has("relativeTo"):
		animation_data._relative_to = full_keyframes_data.relativeTo

	# Flattens the keyframe_data
	var keyframes_data = AnimaTweenUtils.flatten_keyframes_data(full_keyframes_data)

	if keyframes_data.has("initial_values"):
		animation_data.initial_values = keyframes_data.initial_values
		keyframes_data.erase("initial_values")

	if keyframes_data.size() == 1:
		if not keyframes_data.has(0):
			keyframes_data[0] = {}
		else:
			printerr("Please specify at least one key beside 'from'")

			return 0.0

	var previous_key_value := {}
	var wait_time: float = animation_data._wait_time if animation_data.has('_wait_time') else 0.0

	if pivot:
		animation_data.pivot = pivot

	if easing:
		animation_data.easing = easing

	keyframes_data.erase("initial_values")

	var frame_keys: Array = keyframes_data.keys()
	frame_keys.sort_custom(self, "_sort_frame_index")

	var base_data = animation_data.duplicate()
	var node: Node = animation_data.node
	var real_duration := 0.0
	var first_frame_data: Dictionary = keyframes_data["0"] if keyframes_data.has("0") else {}
	
	if keyframes_data.has(0):
		first_frame_data = keyframes_data[0]

	var all_properties_to_animate := []

	for key in keyframes_data:
		if ["from", "to"].has(key) or _is_valid_frame_key(key):
			for property_key in keyframes_data[key]:
				if not all_properties_to_animate.has(property_key) and not property_key == "easing":
					all_properties_to_animate.push_back(property_key)

	for property_to_animate in all_properties_to_animate:
		var current_value = AnimaNodesProperties.get_property_value(node, {}, property_to_animate)
		var first_frame_has_property = first_frame_data.has(property_to_animate)
		var value = first_frame_data[property_to_animate] if first_frame_has_property else current_value

		if value is String:
			value = AnimaTweenUtils.maybe_calculate_value(value, base_data)

		if relative_properties.has(property_to_animate) and first_frame_data.has(property_to_animate):
			value += AnimaNodesProperties.get_property_value(animation_data.node, animation_data, property_to_animate)

		var data := { percentage = 0, value = value }
		if animation_data.has("initial_values") and animation_data.initial_values.has(property_to_animate):
			data.value = animation_data.initial_values[property_to_animate]

		base_data.property = property_to_animate

		var meta_key := "__initial_" + meta_data_prefix + "_" + str(property_to_animate) 

		if node.has_meta(meta_key) and not first_frame_has_property:
			var meta_value = node.get_meta(meta_key)

			if should_debug_print(animation_data, property_to_animate):
				prints("retrieving node meta value", meta_value, data)

			data = meta_value
		else:
			node.set_meta(meta_key, data)

		previous_key_value[property_to_animate] = data

		if typeof(value) != typeof(current_value):
			if typeof(current_value) == TYPE_VECTOR2:
				value = Vector2(value.x, value.y)

#		if current_value != value and relative_properties.find(property_to_animate) < 0:
#			data.initial_value = value

	frame_keys.pop_front()

	#
	# Sometimes we want to be able to define the duration of each single step.
	# For example for "typewrite" we want to specify the duration of the animation of the single
	# character, instead of the full sentences, otherwise different string length will
	# have different speed.
	# In those cases we can define a special key called "_duration" where we can specify a formula
	# using the "dynamic value" capability.
	#
	if full_keyframes_data.has("_duration"):
		var duration_formula = full_keyframes_data._duration.replace("{duration}", animation_data.duration)
		real_duration = AnimaTweenUtils.maybe_calculate_value(duration_formula, animation_data)

		animation_data.duration = real_duration

	if should_debug_print(animation_data, ''):
		prints("add_frames", animation_data)
		prints("", "first:", first_frame_data)
		prints("", "previous:", previous_key_value)
		prints("", "keys:", frame_keys)

	var is_first_frame := true
	for frame_key in frame_keys:
		var is_valid_frame_key = _is_valid_frame_key(frame_key)
		var frame_key_value = str(frame_key).to_float()

		if not is_valid_frame_key or frame_key_value > 100:
			continue

		var keyframe_data: Dictionary = keyframes_data[frame_key]

		animation_data._is_first_frame = is_first_frame
		animation_data._is_last_frame = frame_key_value == 100

		var is_relative: bool = relative_properties.find(frame_key)

		_calculate_frame_data(
			wait_time,
			animation_data,
			relative_properties,
			frame_key_value,
			keyframes_data[frame_key],
			previous_key_value
		)

		animation_data.erase("initial_values")

		is_first_frame= false

	return real_duration

func _is_valid_frame_key(key) -> bool:
	if typeof(key) == TYPE_INT or typeof(key) == TYPE_REAL:
		return true

	return _frame_key_checker.search(key) != null

func _sort_frame_index(a, b) -> bool:
	return str(a).to_float() < str(b).to_float()

func _calculate_frame_data(wait_time: float, animation_data: Dictionary, relative_properties: Array, current_frame_key: float, frame_data: Dictionary, previous_key_value: Dictionary) -> void:
	var duration: float = animation_data.duration if animation_data.has('duration') else 0.0
	var easing = null
	var pivot = null

	if animation_data.has("easing"):
		easing = animation_data.easing

	if frame_data.has("easing"):
		easing = frame_data.easing

	var node: Node = animation_data.node
	var is_mesh = node is MeshInstance
	var keys := []

	for key in frame_data.keys():
		if key == "easing" or key == "pivot":
			continue

		if key == "skew":
			var skew: Vector2 = frame_data[key]

			frame_data["skew:x"] = skew.x / 32
			frame_data["skew:y"] = skew.y / 32

			if previous_key_value.skew and not previous_key_value.has("skew:x"):
				var p: Dictionary = previous_key_value.skew

				previous_key_value["skew:x"] = { percentage = p.percentage, value = p.value.x }
				previous_key_value["skew:y"] = { percentage = p.percentage, value = p.value.y }

			keys.push_back("skew:x")
			key = "skew:y"

		keys.push_back(key)

	for property_to_animate in keys:
		var data = animation_data.duplicate()
		var start_percentage = previous_key_value[property_to_animate].percentage if previous_key_value.has(property_to_animate) else 0
		var percentage = (current_frame_key - start_percentage) / 100.0
		var frame_duration = max(ANIMA.MINIMUM_DURATION, duration * percentage)
		var percentage_delay := 0.0
		var relative = relative_properties.find(property_to_animate) >= 0

		if start_percentage > 0:
			percentage_delay += (start_percentage/ 100.0) * duration

		var from_value

		if previous_key_value.has(property_to_animate):
			from_value = previous_key_value[property_to_animate].value
		else:
			from_value = AnimaNodesProperties.get_property_value(node, animation_data, property_to_animate)

		var to_value = frame_data[property_to_animate]

		#
		# To have generic animations that works with 2D and 3D Nodes
		# we always define scale as Vector3. But for 2D Nodes we can
		# only use Vector2, so in this case we have to "convert" the property
		# internally
		var node_property = AnimaNodesProperties.map_property_to_godot_property(node, property_to_animate)

		var should_convert_to_vector2: bool = not node_property.has("key") and node_property.has("property") and node_property.property in node and node[node_property.property] is Vector2
		if should_convert_to_vector2:
			if from_value is Vector3:
				from_value = Vector2(from_value.x, from_value.y)

			if to_value is Vector3:
				to_value = Vector2(to_value.x, to_value.y)

		var property_name: String = property_to_animate

		data.to = AnimaTweenUtils.maybe_calculate_value(to_value, data)

		if relative:
			if previous_key_value[property_to_animate].has("to"):
				from_value = previous_key_value[property_to_animate].to

			data.to += from_value

		data.property = property_name
		data.duration = frame_duration
		data._wait_time = wait_time + percentage_delay
		data.easing = easing
		data.from = from_value

		if property_name == "opacity":
			data.easing = null

		if should_debug_print(animation_data, data.property):
			prints("\n=== FRAME", data.property, ":", data.from, " --> ", data.to, "wait time:", data._wait_time, "duration:", data.duration, "easing:", data.easing, " is relative:", str(relative))

		if previous_key_value.has(property_to_animate) and previous_key_value[property_to_animate].has("initial_value"):
			if not data.has("initial_values"):
				data.initial_values = {}

			data.initial_values[property_to_animate] = previous_key_value[property_to_animate].initial_value

			_add_initial_values.call_func(data)

		if typeof(from_value) != typeof(data.to) or from_value != data.to:
			_add_animation_data.call_func(data)
		elif animation_data.has("__debug") and (bool(animation_data.__debug) == true or animation_data.__debug == data.property):
			prints("\t SKIPPING, from == to", from_value, data.to)

		previous_key_value[property_to_animate] = { percentage = current_frame_key, value = frame_data[property_to_animate], to = data.to }

func should_debug_print(animation_data: Dictionary, property) -> bool:
	return animation_data.has("__debug") and (animation_data.__debug == "---" or animation_data.__debug == property)
