@tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

var anima_button = preload("res://addons/anima/visual-editor/shared/AnimaButton.tscn")

signal item_selected(id)

@onready var _panel: PopupPanel = $PanelItems

enum SHOW_PANEL_ON {
	HOVER,
	RIGHT_CLICK,
	CLICK
}

@export (SHOW_PANEL_ON) var show_panel_on = SHOW_PANEL_ON.HOVER :
	get:
		return show_panel_on # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_show_panel_on

var _selected_id := 0
var _items: Array

func _on_Button_pressed():
	if show_panel_on == SHOW_PANEL_ON.CLICK:
		_show_panel()

func set_items(items: Array) -> void:
	_items = items

	if _panel.get_child_count() > 0:
		_panel.get_child(0).queue_free()

	var vbox := VBoxContainer.new()

	for index in _items.size():
		var item = _items[index]
		var panel_item = anima_button.instantiate()

		panel_item.icon = load(item.icon)
		panel_item.text = "  " + item.label
		panel_item.align = ALIGN_LEFT

		panel_item.connect("button_down",Callable(self,"_on_PopupMenu_id_pressed").bind(index))
		panel_item.connect("mouse_entered",Callable(self,"_on_PopupPanel_mouse_entered"))
		panel_item.connect("mouse_exited",Callable(self,"_on_Button_mouse_exited"))

		vbox.add_child(panel_item)

	_panel.add_child(vbox)

func _on_PopupMenu_id_pressed(id):
	_on_Timer_timeout()
	set_selected_id(id)

	emit_signal("item_selected", id)

func set_selected_id(id) -> void:
	_selected_id = id

	icon = load(_items[_selected_id].icon)

func get_selected_id() -> int:
	return _selected_id

func _input(event):
	if event is InputEventMouseButton:
		if get_draw_mode() == DRAW_HOVER and show_panel_on == SHOW_PANEL_ON.RIGHT_CLICK and event.button_index == 2 and event.button_pressed == false:
			_show_panel()
		elif event.button_pressed == false:
			_panel.hide()

func _on_Button_mouse_entered():
	if show_panel_on != SHOW_PANEL_ON.HOVER:
		return

	_show_panel()

func _show_panel() -> void:
	_panel.set_position(get_global_position() + Vector2(0, size.y))
	_panel.show()

	_override_draw_mode = DRAW_HOVER

	$Timer.stop()

func _on_Button_mouse_exited():
	$Timer.start()

func _on_Timer_timeout():
	_panel.hide()

func _on_PopupPanel_mouse_entered():
	$Timer.stop()

func _on_PopupPanel_hide():
	_override_draw_mode = null

	_refresh_button(get_draw_mode(), true)

func set_show_panel_on(checked) -> void:
	show_panel_on = checked
