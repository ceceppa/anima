tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

func _on_Preview_toggled(button_pressed):
	._on_Button_toggled(button_pressed)

	var icon_name = "Wait.svg" if button_pressed else "Play.svg"

	icon = load("res://addons/anima/visual-editor/icons/" + icon_name)
