tool
extends VBoxContainer

signal delete_animation
signal play_animation
signal name_updated

onready var _delete_button: Button = find_node("DeleteButton")
onready var _line_edit: LineEdit = find_node("LineEdit")
onready var _visibility_stategy: OptionButton = find_node("VisibilityStrategy")

var _default_name: String

func get_animation_data() -> Dictionary:
	return {
		name = _line_edit.text,
		visibility_strategy = _visibility_stategy.selected
	}

func set_visibility_strategy(strategy: int) -> void:
	if _visibility_stategy == null:
		_visibility_stategy = find_node("VisibilityStrategy")

	_visibility_stategy._select_int(strategy)

func disable_delete_button() -> void:
	_delete_button.hide()

func set_default_name(name: String) -> void:
	_default_name = name

	if _line_edit == null:
		_line_edit = find_node("LineEdit")

	_line_edit.text = name

func set_tooltip(tooltip: String) -> void:
	_line_edit.hint_tooltip = tooltip

func _on_LineEdit_focus_exited():
	if _line_edit.text.strip_edges() == '':
		_line_edit.text = _default_name

func _on_DeleteButton_pressed():
	emit_signal("delete_animation")

	queue_free()

func _on_LineEdit_text_changed(_new_text):
	emit_signal("name_updated")

func _on_OptionButton_item_selected(_index):
	emit_signal("name_updated")
