tool
extends AnimaRectangle

const FRAME_ANIMATION = preload("res://addons/anima/ui/Frames/AnimaFrameAnimation.tscn")
const FRAME_DELAY = preload("res://addons/anima/ui/Frames/AnimaFrameDelay.tscn")

onready var _frames_container = find_node("FramesContainer")

func _ready():
	# I have no idea why if I add the FRAME_ANIMATION via the Editor the +
	# button inside AnimaAddFrame ends up outside the parent container????
	var dotted = find_node("Dotted")

	dotted.margin_left = 0
	dotted.margin_right = 0

func _add_component(node: Node) -> void:
	_frames_container.add_child(node)

func _on_AnimaAddFrame_add_frame():
	_add_component(FRAME_ANIMATION.instance())

func _on_AnimaAddFrame_add_delay():
	_add_component(FRAME_DELAY.instance())
