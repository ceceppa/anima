tool
extends AnimaRectangle

func _ready():
	._ready()

	var frame_name = find_node("FrameName")

	frame_name.set_initial_value("Frame01")
	frame_name.set_placeholder("Frame01")
