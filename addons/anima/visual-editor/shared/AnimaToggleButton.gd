tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

onready var _icon_wrapper = find_node("IconWrapper")

func _init():
	toggle_mode = true

func _ready():
	_on_AnimaToggleButton_toggled(pressed)
	toggle_mode = true

	set_left_padding(48)

func _on_AnimaToggleButton_toggled(button_pressed):
	var path := "res://addons/anima/visual-editor/icons/Closed.svg"

	if button_pressed:
		path = "res://addons/anima/visual-editor/icons/Collapse.svg"

	set('icon', load(path))

	if not get_parent():
		return

	var parent: Node = get_parent()

	if parent.get_child_count() < 2:
		return

	var next = get_parent().get_child(get_index() + 1)

	if next:
		next.visible = button_pressed

func _maybe_set_icon_wrapper() -> void:
	if not _icon_wrapper:
		_icon_wrapper = find_node("IconWrapper")

