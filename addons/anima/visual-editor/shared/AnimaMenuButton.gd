tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

signal item_selected(id)

var _selected_id := 0

func _on_Button_pressed():
	$PopupMenu.rect_position.x = rect_position.x
	$PopupMenu.popup()

func set_items(items: Array) -> void:
	$PopupMenu.clear()

	for item in items:
		$PopupMenu.add_icon_item(load(item.icon), item.label)

func _on_PopupMenu_id_pressed(id):
	_selected_id = id

	emit_signal(id)

func get_selected_id() -> int:
	return _selected_id
