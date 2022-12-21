tool
extends Control

const FRAME_ANIMATION = preload("res://addons/anima/visual-editor/editor/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/visual-editor/editor/AnimaFrameDelay.tscn")

signal add_node(node_path)
signal select_node
signal select_node_property(source, node_path)
signal visual_builder_updated(data)
signal select_animation
signal highlight_nodes(nodes)
signal select_relative_property
signal select_easing
signal preview_animation(preview_info)
signal change_editor_position(new_position)

export (bool) var disable_animations := false

onready var _frames_container1 = find_node("FramesContainer1")
onready var _frames_container2 = find_node("FramesContainer2")
onready var _anima_animation = find_node("AnimaAnimation")

var _destination_frame: Control
var _is_restoring_data := false
var _animation_node_source: Node
var _active_frames_container: Node
var _flow_direction := 0
var _last_id := 0

func _ready():
	if _active_frames_container == null:
		_active_frames_container = _frames_container1

	_active_frames_container.show()

func add_animation_for(node: Node, node_path: String) -> Node:
	var r: Node = _destination_frame.add_animation_for(node, node_path)

	_emit_updated()

	return r

func set_relative_property(node_path: String, property: String) -> void:
	_animation_node_source.set_relative_propert(node_path, property)

func restore_animation_data(data: Dictionary) -> void:
	if _anima_animation == null:
		_anima_animation = find_node("AnimaAnimation")

	_anima_animation.restore_data(data)

func clear() -> void:
	for child in _active_frames_container.get_children():
		child.animate_entrance_exit = false
		child.queue_free()

func select_frame(key) -> Node:
	_destination_frame = null

	for child in _active_frames_container.get_children():
		if is_instance_valid(child) and child.get_meta("_key") == key:
			_destination_frame = child

	return _destination_frame

func set_frame_name(name: String) -> void:
	_destination_frame.set_name(name)

func set_frame_duration(duration: float) -> void:
	_destination_frame.set_duration(duration)

func set_is_restoring_data(is_restoring: bool) -> void:
	_is_restoring_data = is_restoring
	
func update_flow_direction(new_direction: int) -> void:
	_flow_direction = new_direction

	_frames_container1.hide()
	_frames_container2.hide()

	_active_frames_container = _frames_container2 if new_direction == 1 else _frames_container1
	_active_frames_container.show()
	
	_anima_animation.set_default_editor_position(new_direction)

func _add_component(node: Node) -> void:
	node.connect("frame_updated", self, "_emit_updated")
	node.connect("frame_deleted", self, "_emit_updated")

	node.animate_entrance_exit = not disable_animations

	_active_frames_container.add_child(node)

	node.animate_entrance_exit = true

func _on_AnimaAddFrame_add_frame(id: int = -1, key := -1):
	if key < 0:
		key = _active_frames_container.get_child_count()

	var node = FRAME_ANIMATION.instance()

	node.connect("highlight_nodes", self, "_on_highlight_node")
	node.connect("select_animation", self, "_on_select_animation", [node])
	node.connect("select_relative_property", self, "_on_select_relative_property", [node])
	node.connect("select_node_property", self, "_on_select_node_property")
	node.connect("select_easing", self, "_on_select_easing", [node])
	node.connect("select_node", self, "_on_frame_select_node", [node])
	node.connect("add_node", self, "_on_frame_add_node", [node])
	node.connect("preview_animation", self, "_on_preview_animation")

	if id < 0:
		id = _last_id + 1

	var color_id = id
	if color_id > ANIMA._FRAME_COLORS.size():
		color_id = id % ANIMA._FRAME_COLORS.size()

	node.set_color(ANIMA._FRAME_COLORS[color_id])

	node.set_meta("_key", key)
	node.set_meta("_data_index", key)
	node.set_title_as_toggable(_flow_direction == 1)
	node.set_name("Frame" + str(key))

	_add_component(node)

	_emit_updated()

	_last_id = id

func _on_AnimaAddFrame_add_delay(key := -1):
	if key < 0:
		key = _active_frames_container.get_child_count()

	var node = FRAME_DELAY.instance()

	node.set_meta("_key", key)

	_add_component(node)

	_emit_updated()

	return node

func _on_frame_select_node(node: Node) -> void:
	_destination_frame = node

	emit_signal("select_node")

func _emit_updated() -> void:
	if _is_restoring_data or _anima_animation == null:
		return

	var data := {
		"0": {
			animation = _anima_animation.get_data(),
			frames = {}
		}
	}

	for index in _active_frames_container.get_child_count():
		var child: Control = _active_frames_container.get_child(index)

		if not child.is_queued_for_deletion():
			data["0"].frames[index] = child.get_data()

	emit_signal("visual_builder_updated", data)

func _on_AnimaAnimation_animation_updated():
	_emit_updated()

func _on_highlight_node(source) -> void:
	emit_signal("highlight_nodes", source)

func _on_select_animation(source: Node) -> void:
	_animation_node_source = source

	emit_signal("select_animation")

func selected_animation(label, name) -> void:
	_anima_animation.selected_animation(label, name)

func set_easing(name: String, value: int) -> void:
	_anima_animation.set_easing(name, value)

func _on_select_relative_property(source: Node) -> void:
	_animation_node_source = source

	emit_signal("select_relative_property")

func _on_select_node_property(source: Node, path: String) -> void:
	emit_signal("select_node_property", source, path)

func _on_select_easing(source: Node) -> void:
	_animation_node_source = source

	emit_signal("select_easing")

func _on_AnimaAnimation_play_animation(animation_info: Dictionary):
	emit_signal("preview_animation", animation_info)

func _on_frame_add_node(node_path, destination_frame) -> void:
	_destination_frame = destination_frame

	emit_signal("add_node", node_path)

func _on_preview_animation(preview_info) -> void:
	emit_signal("preview_animation",preview_info)

func get_selected_animation_name() -> String:
	return _anima_animation.get_selected_animation_name()

func _on_AnimaAnimation_change_editor_position(new_position):
	emit_signal("change_editor_position", new_position)

func _on_AnimaAnimation_collapse_all():
	_set_child_as_collapsed(true)

func _on_AnimaAnimation_expand_all():
	_set_child_as_collapsed(false)

func _set_child_as_collapsed(collapsed: bool) -> void:
	for child in _active_frames_container.get_children():
		if child.has_method("set_collapsed"):
			child.call_deferred("set_collapsed", collapsed)
