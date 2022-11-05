tool
extends Control

var _is_collapsed_mode := true

signal add_frame
signal add_event
signal add_delay

func _ready():
	var final_width: float = 360

#	rect_min_size.x = final_width
#	rect_size.x = final_width

func _on_Animation_pressed():
	emit_signal("add_frame")

func _on_Delay_pressed():
	emit_signal("add_delay")

func _on_Event_pressed():
	emit_signal("add_event")
