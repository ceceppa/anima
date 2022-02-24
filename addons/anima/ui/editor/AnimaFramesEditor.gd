tool
extends AnimaRectangle

const FRAME_ANIMATION = preload("res://addons/anima/ui/editor/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/ui/editor/AnimaFrameDelay.tscn")

signal select_node

onready var _frames_container = find_node("FramesContainer")

var _destination_frame: Control

func _ready():
	# I have no idea why if I add the FRAME_ANIMATION via the Editor the +
	# button inside AnimaAddFrame ends up outside the parent container????
	var dotted = find_node("Dotted")

	dotted.margin_left = 0
	dotted.margin_right = 0

func add_animation_for(node: Node, node_path: String) -> void:
	_frames_container.add_animation_for(node, node_path)

func _add_component(node: Node) -> void:
	_frames_container.add_child(node)

func _on_AnimaAddFrame_add_frame():
	_add_component(FRAME_ANIMATION.instance())

func _on_AnimaAddFrame_add_delay():
	_add_component(FRAME_DELAY.instance())

func _on_InitialFrame_select_node():
	_destination_frame = find_node("InitialFrame")

	emit_signal("select_node")
