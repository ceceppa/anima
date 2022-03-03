tool
extends Control

const FRAME_ANIMATION = preload("res://addons/anima/ui/editor/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/ui/editor/AnimaFrameDelay.tscn")

signal select_node
signal visual_builder_updated(data)

export (bool) var disable_animations := false

onready var _frames_container = find_node("FramesContainer")
onready var _initial_frame = find_node("InitialFrame")

var _destination_frame: Control

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

func clear() -> void:
	for index in range(1, _frames_container.get_child_count()):
		var child = _frames_container.get_child(index)

		child.animate_entrance_exit = false
		child.queue_free()

	_initial_frame.clear()

func select_frame(index: int) -> void:
	_destination_frame = _frames_container.get_child(index)

func set_frame_name(name: String) -> void:
	_destination_frame.set_name(name)

func set_frame_duration(duration: float) -> void:
	_destination_frame.set_duration(duration)

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

func _on_InitialFrame_select_node():
	_destination_frame = find_node("InitialFrame")

	emit_signal("select_node")

func _on_frame_select_node(node: Node) -> void:
	_destination_frame = node

	emit_signal("select_node")

func _emit_updated() -> void:
	var data := {
		"0": {
			name = "animation",
			frames = {}
		}
	}

	for index in _frames_container.get_child_count():
		var child: Control = _frames_container.get_child(0)

		data["0"].frames[index] = child.get_data()

	emit_signal("visual_builder_updated", data)

func _on_InitialFrame_frame_updated():
	_emit_updated()
