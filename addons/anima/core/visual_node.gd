tool
class_name AnimaVisualNode
extends Node

signal animation_completed
signal on_editor_position_changed(new_position)

enum EDITOR_POSITION {
	BOTTOM,
	CANVAS_RIGHT,
	DOCK_RIGHT
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

export (Dictionary) var __anima_visual_editor_data = {}
export (EDITOR_POSITION) var _editor_position := EDITOR_POSITION.BOTTOM setget set_editor_position

var _initial_values := {}
var _active_anima_node: AnimaNode

func _init():
	set_meta("__anima_visual_node", true)

#
# Returns the node that Anima will use when handling the animations
# done via visual editor
#
func get_root_node() -> Node:
	var parent = self.get_parent()

#	# get data
#	var img = get_viewport().get_texture().get_data()
#	# wait two frames
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	# flip
#	img.flip_y()
#	# get screen ratio + resize capture
#	var ratio = 2
#	img.resize(img.get_width()*ratio,img.get_height()*ratio,0)
#	# save to file
#	print("saving")
#	img.save_png("screenshot.png")

	if parent == null:
		return self

	return parent

func get_animations_list() -> Array:
	var animations := []

	if __anima_visual_editor_data.has('animations'):
		return __anima_visual_editor_data.animations

	return []

func play_animation(name: String, speed: float = 1.0, reset_initial_values := false) -> void:
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

func _play_animation_from_data(animation_name: String, animations_data: Dictionary, speed: float, reset_initial_values: bool) -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self, animation_name)
	var visibility_strategy: int = animations_data.animation.visibility_strategy
	var default_duration = animations_data.animation.default_duration
	var timeline_debug := {}

	anima.set_root_node(get_root_node())
	anima.set_visibility_strategy(visibility_strategy)

	if default_duration == null:
		default_duration = ANIMA.DEFAULT_DURATION

	for frame_id in animations_data.frames:
		var frame_data = animations_data.frames[frame_id]
		var frame_default_duration = frame_data.duration

		if frame_default_duration == null:
			frame_default_duration = default_duration
		
		anima.set_default_duration(frame_default_duration)

		for animation in frame_data.data:
			var data: Dictionary = _create_animation_data(animation)

			data._wait_time = 0 #animation.start_time

			if not timeline_debug.has(data._wait_time):
				timeline_debug[data._wait_time] = []

			var what = data.property if data.has("property") else data.animation

			var duration = data.duration if data.has("duration") else frame_default_duration
			var delay = data.delay if data.has("delay") else 0.0

			timeline_debug[data._wait_time].push_back({ 
				duration = duration,
				delay = delay,
				what = what
			})

			anima.with(data)

	var keys = timeline_debug.keys()
	keys.sort()

	for k in keys:
		for d in timeline_debug[k]:
			var s: float = k + d.delay
			print(".".repeat(s * 10), "▒".repeat(float(d.duration) * 10), " --> ", "from: ", s, "s to: ", s + d.duration, "s => ", d.what)

	_active_anima_node = anima

#	anima.debug()
	anima.play_with_delay(1.0)

	yield(anima, "animation_completed")

	if reset_initial_values:
		_reset_initial_values()

	emit_signal("animation_completed")
#
#func preview_animation(node: Node, duration: float, delay: float, animation_data: Dictionary) -> void:
#	var anima: AnimaNode = Anima.begin(self)
#	anima.set_single_shot(true)
#
#	var initial_value = null
#
#	var anima_data = _create_animation_data(node, duration, delay, animation_data)
#	anima.set_root_node(get_root_node())
#
#	AnimaUI.debug(self, 'playing node animation with data', anima_data)
#
#	anima_data._root_node = get_root_node()
#
#	anima.then(anima_data)
#
#	anima.play()
#	yield(anima, "animation_completed")
#
#	_reset_initial_values()

func stop() -> void:
	if _active_anima_node == null:
		return

	_active_anima_node.stop()
	_reset_initial_values()

func _create_animation_data(animation_data: Dictionary) -> Dictionary:
	var source_node: Node = get_root_node()
	var node_path: String = animation_data.node_path
	var node: Node = source_node.get_node(node_path)

	var anima_data = {
		node = node,
		__ignore_warning = true
	}

	if animation_data.duration:
		anima_data.duration = animation_data.duration

	if animation_data.delay:
		anima_data.delay = animation_data.delay

	if animation_data.has("animate_as"):
		if animation_data.animate_as == ANIMATE_AS.GROUP:
			anima_data.erase("node")
			anima_data.group = node
		elif animation_data.animate_as == ANIMATE_AS.GRID:
			anima_data.erase("node")
			anima_data.grid = node
	
	if animation_data.has("group"):
		anima_data.animation_type = animation_data.group.animation_type
		anima_data.items_delay = animation_data.group.items_delay
		anima_data.point = Vector2(animation_data.group.start_index, 0)

	# Default properties to reset to their initial value when the animation preview is completed
	var properties_to_reset := ["modulate", "position", "size", "rotation", "scale"]

	if animation_data.use == 1:
		anima_data.animation = animation_data.animation_name
	else:
		var node_name: String = node.name
		var property: String = animation_data.property_name

		properties_to_reset.clear()
		properties_to_reset.push_back(property)

		anima_data.property = property

		for key in animation_data.property:
			if key == 'pivot':
				var pivot = animation_data.property.pivot

				if pivot >= 0:
					anima_data.pivot = pivot
			elif key == "easing":
				anima_data.easing = animation_data.property.easing[1]
			elif key == "from":
				var from = animation_data.property.from

				if from is String and from.find(":") >= 0:
					anima_data.from = from
				elif from is Array:
					if from.size() == 2:
						anima_data.from = Vector2(from[0], from[1])
					else:
						anima_data.from = Vector3(from[0], from[1], from[2])
				else:
					anima_data.from = float(from)
			elif key == "to":
				var to = animation_data.property.to

				if to is String and to.find(":") >= 0:
					anima_data.from = to
				elif to is Array:
					if to.size() == 2:
						anima_data.to = Vector2(to[0], to[1])
					else:
						anima_data.to = Vector3(to[0], to[1], to[2])
				else:
					anima_data.to = float(to)
			else:
				var value = animation_data.property[key]
				
				if value != null:
					anima_data[key] = animation_data.property[key]

	for property in properties_to_reset:
		if not _initial_values.has(node) or not _initial_values[node].has(property):
			if not _initial_values.has(node):
				_initial_values[node] = {}

			_initial_values[node][property] = AnimaNodesProperties.get_property_value(node, { property = property })


	anima_data._root_node = source_node

	return anima_data

func _reset_initial_values() -> void:
	_active_anima_node = null

	yield(get_tree().create_timer(1.0), "timeout")

	# reset node initial values
	if _initial_values.size() == 0:
		return

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

func set_editor_position(new_position: int) -> void:
	_editor_position = new_position

	emit_signal("on_editor_position_changed", new_position)
