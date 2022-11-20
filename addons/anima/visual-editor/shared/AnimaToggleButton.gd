tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

export (Texture) var left_icon setget set_left_icon

onready var _left_icon = find_node("LeftIcon")
onready var _icon_wrapper = find_node("IconWrapper")

func _init():
	toggle_mode = true

func _ready():
	_on_AnimaToggleButton_toggled(pressed)
	toggle_mode = true

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

func set_left_icon(new_icon: Texture) -> void:
	left_icon = new_icon

	_maybe_set_icon_wrapper()

	if _icon_wrapper:
		_icon_wrapper.visible = new_icon != null

	if _left_icon:
		_left_icon.texture = left_icon

		_adjust_icon_position()

	if left_icon:
		set_left_padding(64)
	else:
		set_left_padding(PADDING)

func _adjust_icon_position() -> void:
	var icon_size = _left_icon.texture.get_size()
	
	_maybe_set_icon_wrapper()

	_left_icon.position = (_icon_wrapper.rect_size - icon_size) / 2

func _maybe_set_icon_wrapper() -> void:
	if not _icon_wrapper:
		_icon_wrapper = find_node("IconWrapper")

