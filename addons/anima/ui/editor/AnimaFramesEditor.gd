tool
extends Control

const FRAME_ANIMATION = preload("res://addons/anima/ui/editor/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/ui/editor/AnimaFrameDelay.tscn")

signal select_node
signal visual_builder_updated(data)

export (bool) var disable_animations := false

onready var _frames_container = find_node("FramesContainer")
onready var _anima_animation = find_node("AnimaAnimation")

var _destination_frame: Control
var _is_restoring_data := false

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

func restore_animation_data(data: Dictionary) -> void:
	if _anima_animation == null:
		_anima_animation = find_node("AnimaAnimation")

	_anima_animation.restore_data(data)

func clear() -> void:
	for child in _frames_container.get_children():
		child.animate_entrance_exit = false
		child.queue_free()

func select_frame(index: int) -> void:
	_destination_frame = _frames_container.get_child(index)

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

func _on_AnimaAddFrame_add_frame():
	_add_component(FRAME_ANIMATION.instance())

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

		data["0"].frames[index] = child.get_data()

	emit_signal("visual_builder_updated", data)

func _on_AnimaAnimation_animation_updated():
	_emit_updated()
