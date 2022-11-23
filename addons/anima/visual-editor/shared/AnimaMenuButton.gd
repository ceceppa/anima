tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

signal item_selected(id)

var _selected_id := 0
var _items: Array

func _on_Button_pressed():
	$PopupMenu.set_position(get_global_position())
	$PopupMenu.show()

func set_items(items: Array) -> void:
	_items = items

	$PopupMenu.clear()

	for item in _items:
		$PopupMenu.add_icon_item(load(item.icon), item.label)

func _on_PopupMenu_id_pressed(id):
	set_selected_id(id)

	emit_signal("item_selected", id)

func set_selected_id(id) -> void:
	_selected_id = id

	icon = load(_items[_selected_id].icon)

func get_selected_id() -> int:
	return _selected_id

func _input(event):
	if event is InputEventMouseButton and event.pressed == false:
		$PopupMenu.hide()
