tool
class_name AnimaVisualNode
extends Node

signal animation_completed

export (Dictionary) var __anima_visual_editor_data = {}

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

	_play_animation_from_data(animations_data, speed, reset_initial_values)

func _get_animation_data_by_name(animation_name: String) -> Dictionary:
	var animations := get_animations_list()
	var data_by_animation = __anima_visual_editor_data.data_by_animation

	if data_by_animation == null:
		return {}

	for animation_id in animations.size():
		var animation: Dictionary = animations[animation_id]

		if animation.name == animation_name:
			return {
				data = data_by_animation[animation_id],
				visibility_strategy = animation.visibility_strategy
			}

	return {}

func _play_animation_from_data(animations_data: Dictionary, speed: float, reset_initial_values: bool) -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self)
	var visibility_strategy: int = animations_data.visibility_strategy
	var timeline_debug := {}
	
	anima.set_root_node(get_root_node())
	anima.set_visibility_strategy(visibility_strategy)

	var source_node: Node = get_root_node()

	for animation in animations_data.data:
		var node_path: String = animation.node_path
		var node: Node = source_node.get_node(node_path)
		
		AnimaUI.debug(self, "getting node from path:", node_path, node)
		var data: Dictionary = _create_animation_data(node, animation.data.duration, animation.data.delay, animation.data.animation_data)

		data._root_node = source_node
		data._wait_time = animation.start_time

		if not timeline_debug.has(data._wait_time):
			timeline_debug[data._wait_time] = []

		var what = data.property if data.has("property") else data.animation

		timeline_debug[data._wait_time].push_back({ duration = data.duration, delay = data.delay, what = what })

		anima.with(data)

	var keys = timeline_debug.keys()
	keys.sort()

	for k in keys:
		for d in timeline_debug[k]:
			var s: float = k + d.delay
			print(".".repeat(s * 10), "▒".repeat(float(d.duration) * 10), " --> ", "from: ", s, " to: ", s + d.duration, " => ", d.what)

	_active_anima_node = anima
	anima.play_with_speed(speed)

	yield(anima, "animation_completed")

	if reset_initial_values:
		_reset_initial_values()

	emit_signal("animation_completed")

func preview_animation(node: Node, duration: float, delay: float, animation_data: Dictionary) -> void:
	var anima: AnimaNode = Anima.begin(self)
	anima.set_single_shot(true)

	var initial_value = null

	var anima_data = _create_animation_data(node, duration, delay, animation_data)
	anima.set_root_node(get_root_node())

	AnimaUI.debug(self, 'playing node animation with data', anima_data)

	anima_data._root_node = get_root_node()

	anima.then(anima_data)

	anima.play()
	yield(anima, "animation_completed")

	_reset_initial_values()

func stop() -> void:
	if _active_anima_node == null:
		return

	_active_anima_node.stop()
	_reset_initial_values()

func _create_animation_data(node: Node, duration: float, delay: float, animation_data: Dictionary) -> Dictionary:
	var anima_data = {
		node = node,
		duration = duration,
		delay = delay
	}

	if animation_data.has("animate_as"):
		if animation_data.animate_as == 1:
			anima_data.erase("node")
			anima_data.group = node
		elif animation_data.animate_as == 2:
			anima_data.erase("node")
			anima_data.grid = node
		
	# Default properties to reset to their initial value when the animation preview is completed
	var properties_to_reset := ["modulate", "position", "size", "rotation", "scale"]

	if animation_data.type == AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION:
		anima_data.animation = animation_data.animation.name
	else:
		var node_name: String = node.name
		var property: String = animation_data.property.name

		properties_to_reset.clear()
		properties_to_reset.push_back(animation_data.property.name)

		for key in animation_data.property:
			if key == 'name':
				anima_data.property = animation_data.property.name
			elif key == 'pivot':
				var pivot = animation_data.property.pivot

				if pivot[0] == 1:
					anima_data.pivot = pivot[1]
			else:
				var value = animation_data.property[key]
				
				if value != null:
					anima_data[key] = animation_data.property[key]

	for property in properties_to_reset:
		if not _initial_values.has(node) or not _initial_values[node].has(property):
			if not _initial_values.has(node):
				_initial_values[node] = {}

			_initial_values[node][property] = AnimaNodesProperties.get_property_value(node, { property = property })

	print(anima_data)

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
