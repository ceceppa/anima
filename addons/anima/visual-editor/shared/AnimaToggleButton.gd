tool
extends Button

func _init():
	toggle_mode = true

func _ready():
	_on_AnimaToggleButton_toggled(pressed)

func _on_AnimaToggleButton_toggled(button_pressed):
	var path := "res://addons/anima/visual-editor/icons/collapse.svg"

	if button_pressed:
		path = "res://addons/anima/visual-editor/icons/Close.svg"

	icon = load(path)

	if not get_parent():
		return

	var next = get_parent().get_child(get_index() + 1)

	if next:
		next.visible = button_pressed
