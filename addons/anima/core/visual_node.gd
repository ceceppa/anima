@tool
class_name AnimaVisualNode
extends Node

signal animation_completed
signal on_editor_position_changed(new_position)

enum EDITOR_POSITION {
	BOTTOM,
	RIGHT,
}

enum USE {
	ANIMATE_PROPERTY,
	ANIMATION
}

enum ANIMATE_AS {
	NODE,
	GROUP,
	GRID
}

@export (Dictionary) var __anima_visual_editor_data = {}
@export (EDITOR_POSITION) var _editor_position := EDITOR_POSITION.BOTTOM :
	get:
		return _editor_position # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_editor_position

var _initial_values := {}
var _active_anima_node: AnimaNode
var _is_playing := false

func _init():
	set_meta("__anima_visual_node", true)

#
# Returns the node that Anima will use when handling the animations
# done via visual editor
#
func get_root_node() -> Node:
	var parent = self.get_parent()

	if parent == null:
		return self

	return parent

func get_animations_list() -> Array:
	var animations := []

	if __anima_visual_editor_data.has('animations'):
		return __anima_visual_editor_data.animations

	return []

func play_animation(name: String, speed: float = 1.0, reset_initial_values := false) -> void:
	var result = reset_scene(0.0)
	await result.completed

	var animations_data: Dictionary = _get_animation_data_by_name(name)

	if animations_data.size() == 0:
		printerr("The selected animation is empty") 

		return

	_play_animation_from_data(name, animations_data, speed, reset_initial_values)

func _get_animation_data_by_name(animation_name: String) -> Dictionary:
	for animation_id in __anima_visual_editor_data:
		var animation_data = __anima_visual_editor_data[animation_id]
		var name = animation_data.animation.name

		if name == null or name == animation_name:
			return animation_data

	return {}

func _play_animation_from_data(
	animation_name: String,
	animations_data: Dictionary,
	speed: float,
	reset_initial_values: bool
) -> void:
	if _is_playing:
		return

	_is_playing = true

	var anima: AnimaNode = Anima.begin_single_shot(self, animation_name)
	var visibility_strategy: int = animations_data.animation.visibility_strategy
	var default_duration = animations_data.animation.default_duration
	var timeline_debug := {}
	var start_time := 0.0

	anima.set_root_node(get_root_node())
	anima.set_visibility_strategy(visibility_strategy)

	if default_duration == null:
		default_duration = ANIMA.DEFAULT_DURATION

	for frame_id in animations_data.frames.keys():
		var frame_data = animations_data.frames[frame_id]

		if frame_data.type == "delay":
			start_time += frame_data.data.delay

			continue

		var frame_default_duration = frame_data.duration

		if frame_default_duration == null:
			frame_default_duration = default_duration

		anima.set_default_duration(frame_default_duration)

		for animation in frame_data.data:
			var data: Dictionary = _create_animation_data(animation)

			data._wait_time = start_time #animation.start_time
#			data.__debug = "---"

			if not timeline_debug.has(data._wait_time):
				timeline_debug[data._wait_time] = []

			var what = data.property if data.has("property") else data.animation

			var duration = data.duration if data.has("duration") else frame_default_duration
			var delay = data.delay if data.has("delay") else 0.0

			timeline_debug[data._wait_time].push_back({ 
				duration = duration,
				delay = delay,
				what = what,
			})

			anima.with(data)

		start_time += frame_default_duration + 0.1

	var keys = timeline_debug.keys()
	keys.sort()

	for k in keys:
		for d in timeline_debug[k]:
			var s: float = k + d.delay
			print(".".repeat(s * 10), "▒".repeat(float(d.duration) * 10), " --> ", "from: ", s, "s to: ", s + d.duration, "s => ", d.what)

	_active_anima_node = anima

	var anima_data = anima.get_animation_data()
	for data in anima_data:
		var node = data.node
		var property_to_reset = data.property

		if not _initial_values.has(node) or not _initial_values[node].has(property_to_reset):
			if not _initial_values.has(node):
				_initial_values[node] = {}

			_initial_values[node][property_to_reset] = AnimaNodesProperties.get_property_value(node, { property = property_to_reset })

	anima.play()

	await anima.animation_completed

	if reset_initial_values:
		await reset_scene(1.0).completed

	emit_signal("animation_completed")

	_is_playing = false

func stop() -> void:
	if _active_anima_node == null:
		return

	_active_anima_node.stop()
	reset_scene(1.0)

func _create_animation_data(animation_data: Dictionary) -> Dictionary:
	var source_node: Node = get_root_node()
	var node_path: String = animation_data.node_path
	var node: Node = source_node.get_node(node_path)


	var anima_data = {
		node = node,
	}

	if animation_data.duration:
		anima_data.duration = animation_data.duration

	if animation_data.delay:
		anima_data.delay = animation_data.delay

	if animation_data.has("animate_as"):
		if animation_data.animate_as == ANIMATE_AS.GROUP:
			anima_data.erase("node")
			anima_data.group = node

			anima_data.items_delay = animation_data.group.items_delay
			anima_data.animation_type = animation_data.group.animation_type
			anima_data.start_index = animation_data.group.start_index
		elif animation_data.animate_as == ANIMATE_AS.GRID:
			anima_data.erase("node")
			anima_data.grid = node

			anima_data.grid_size = animation_data.grid.size
			anima_data.items_delay = animation_data.grid.items_delay
			anima_data.animation_type = animation_data.grid.animation_type
			anima_data.start_point = animation_data.grid.start_point
			anima_data.distance_formula = animation_data.grid.formula

	# Default properties to reset to their initial value when the animation preview is completed
	var properties_to_reset := ["modulate", "position", "size", "rotation", "scale"]

	for animation in animation_data.animations:
		if animation.animate_with == USE.ANIMATION:
			anima_data.animation = animation.animation_name
		else:
			var node_name: String = node.name
			var property: String = animation.property_name

			properties_to_reset.clear()
			properties_to_reset.push_back(property)

			anima_data.property = property

			for key in animation.property:
				if key == 'pivot':
					var pivot = animation.property.pivot

					if pivot >= 0:
						anima_data.pivot = pivot
				elif key == "easing":
					anima_data.easing = animation.property.easing[1]
				elif key == "from":
					anima_data.from = _extract_value(animation.property.from)
				elif key == "to":
					anima_data.to = _extract_value(animation.property.to)
				else:
					var value = animation.property[key]
					
					if value != null:
						anima_data[key] = animation.property[key]
	anima_data._root_node = source_node

	return anima_data

func _extract_value(value):
	if value is String and value.find(":") >= 0:
		return value
	elif value is Array:
		if value.size() == 2:
			return Vector2(value[0], value[1])
		else:
			return Vector3(value[0], value[1], value[2])
	elif value != null:
		return float(value)

	return null

func reset_scene(clear_timeout: float):
	if is_instance_valid(_active_anima_node) and not _active_anima_node.is_queued_for_deletion():
		_active_anima_node.stop()
	else:
		return await get_tree().idle_frame

	_active_anima_node = null

	await get_tree().create_timer(clear_timeout).timeout

	# reset node initial values
	if _initial_values.size() == 0:
		return await get_tree().idle_frame

	for node in _initial_values:
		var initial_values: Dictionary = _initial_values[node]

		for property in initial_values:
			var initial_value = initial_values[property]

			var mapped_property = AnimaNodesProperties.map_property_to_godot_property(node, property)

			if mapped_property.has('callback'):
				mapped_property.callback.call_func(mapped_property.param, initial_value)
			elif mapped_property.has('subkey'):
				node[mapped_property.property][mapped_property.key][mapped_property.subkey] = initial_value
			elif mapped_property.has('key'):
				node[mapped_property.property][mapped_property.key] = initial_value
			else:
				node[mapped_property.property] = initial_value

		if node.has_meta("_old_modulate"):
			node.remove_meta("_old_modulate")

	_initial_values.clear()

	await get_tree().idle_frame

func set_editor_position(new_position: int) -> void:
	_editor_position = new_position

	emit_signal("on_editor_position_changed", new_position)

func preview_animation(preview_info: Dictionary) -> void:
	var animations_data: Dictionary = _get_animation_data_by_name(preview_info.animation_name)

	if _is_playing:
		return

	if animations_data.size() == 0:
		printerr("The selected animation is empty") 

		return

	var preview_button: Button = preview_info.preview_button

	var single_animation_data := {}
	
	if preview_info.has("frame_id"):
		single_animation_data.animation = animations_data.animation

		single_animation_data.frames = {
			0: animations_data.frames[preview_info.frame_id].duplicate()
		}
	else:
		single_animation_data = animations_data

	if preview_info.has("animation_data_id"):
		single_animation_data.frames.erase("data")

		single_animation_data.frames[0].data = [
			animations_data.frames[preview_info.frame_id].data[preview_info.animation_data_id].duplicate()
		]

	if preview_info.has("single_animation_id"):
		single_animation_data.frames[0].data[0].erase("animations")

		single_animation_data.frames[0].data[0].animations = [
			animations_data.frames[preview_info.frame_id].data[preview_info.animation_data_id].animations[preview_info.single_animation_id]
		]

	if single_animation_data.frames[0].data[0].animations.size() == 0:
		return
		
	preview_button.button_pressed = true

	var doit = _play_animation_from_data("_single_animation", single_animation_data, 1.0, true)

	await doit.completed

	preview_button.button_pressed = false
