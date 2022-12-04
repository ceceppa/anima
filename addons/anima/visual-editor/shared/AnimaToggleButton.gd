@tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

@export (NodePath) var node_to_toggle

@onready var _icon_wrapper = find_child("IconWrapper")

var _node_to_toggle: Node

func _init():
	toggle_mode = true

func _ready():
	_on_AnimaToggleButton_toggled(pressed)

	toggle_mode = true
	_ignore_toggle_mode = true

	if node_to_toggle != "":
		_node_to_toggle = get_node(node_to_toggle)

		return

	var parent: Node = get_parent()

	if parent and parent.get_child_count() < 2:
		return

	_node_to_toggle = get_parent().get_child(get_index() + 1)

	set_left_padding(48)

func _on_AnimaToggleButton_toggled(button_pressed):
	var path := "res://addons/anima/visual-editor/icons/Closed.svg"

	if button_pressed:
		path = "res://addons/anima/visual-editor/icons/Collapse.svg"

	set('icon', load(path))

	if not get_parent():
		return

	if _node_to_toggle:
		_node_to_toggle.visible = button_pressed

func _maybe_set_icon_wrapper() -> void:
	if not _icon_wrapper:
		_icon_wrapper = find_child("IconWrapper")

