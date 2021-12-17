tool
extends MarginContainer

signal delete_event

var _default_name: String

func set_label(name: String) -> void:
	$HBoxContainer/Label.text = name

func _on_DeleteButton_pressed():
	emit_signal("delete_event")

