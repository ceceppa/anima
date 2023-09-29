@tool
extends Button

func _on_toggled(button_pressed):
	if button_pressed:
		icon = load("res://addons/anima/icons/Collapse.svg")
	else:
		icon = load("res://addons/anima/icons/Closed.svg")
