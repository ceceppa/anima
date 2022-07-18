tool
extends Control

const FRAME_ANIMATION = preload("res://addons/anima/ui/editor/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/ui/editor/AnimaFrameDelay.tscn")

signal select_node
signal visual_builder_updated(data)
signal select_animation
signal highlight_node(node)
signal select_relative_property
signal select_easing

export (bool) var disable_animations := false

onready var _frames_container = find_node("FramesContainer")
onready var _anima_animation = find_node("AnimaAnimation")

var _destination_frame: Control
var _is_restoring_data := false
var _animation_node_source: Node

func _ready():
	# I have no idea why if I add the FRAME_ANIMATION via the Editor the +
	# button inside AnimaAddFrame ends up outside the parent container????
	var dotted = find_node("Dotted")

	dotted.margin_left = 0
	dotted.margin_right = 0

func add_animation_for(node: Node, node_path: String, property_name, property_type) -> Node:
	var r: Node = _destination_frame.add_animation_for(node, node_path, property_name, property_type)

	_emit_updated()

	return r

func set_relative_property(node_path: String, property: String) -> void:
	_animation_node_source.set_relative_propert(node_path, property)

func restore_animation_data(data: Dictionary) -> void:
	if _anima_animation == null:
		_anima_animation = find_node("AnimaAnimation")

	_anima_animation.restore_data(data)

func clear() -> void:
	for child in _frames_container.get_children():
		child.animate_entrance_exit = false
		child.queue_free()

func select_frame(key) -> void:
	for child in _frames_container.get_children():
		if is_instance_valid(child) and child.get_meta("_key") == key:
			_destination_frame = child

func set_frame_name(name: String) -> void:
	_destination_frame.set_name(name)

func set_frame_duration(duration: float) -> void:
	_destination_frame.set_duration(duration)

func set_is_restoring_data(is_restoring: bool) -> void:
	_is_restoring_data = is_restoring

func _add_component(node: Node) -> void:
	node.connect("frame_updated", self, "_emit_updated")
	node.connect("frame_deleted", self, "_emit_updated")
	node.connect("select_node", self, "_on_frame_select_node", [node])

	node.animate_entrance_exit = not disable_animations

	_frames_container.add_child(node)

	node.animate_entrance_exit = true

func _on_AnimaAddFrame_add_frame(key := -1, is_initial_frame := false):
	if key < 0:
		key = _frames_container.get_child_count()

	var node = FRAME_ANIMATION.instance()

	node.connect("highlight_node", self, "_on_highlight_node")
	node.connect("select_animation", self, "_on_select_animation", [node])
	node.connect("select_relative_property", self, "_on_select_relative_property", [node])
	node.connect("select_easing", self, "_on_select_easing", [node])
	node.set_is_initial_frame(is_initial_frame)
	node.set_meta("_key", key)
	node.set_name("Frame" + str(key))

	_add_component(node)

	_emit_updated()

func _on_AnimaAddFrame_add_delay():
	_add_component(FRAME_DELAY.instance())

	_emit_updated()

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

	for index in _frames_container.get_child_count():
		var child: Control = _frames_container.get_child(index)

		if not child.is_queued_for_deletion():
			data["0"].frames[index] = child.get_data()

	emit_signal("visual_builder_updated", data)

func _on_AnimaAnimation_animation_updated():
	_emit_updated()

func _on_highlight_node(source: Node) -> void:
	emit_signal("highlight_node", source)

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

func _on_select_easing(source: Node) -> void:
	_animation_node_source = source

	emit_signal("select_easing")
