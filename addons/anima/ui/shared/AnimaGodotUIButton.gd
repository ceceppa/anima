tool
extends Button

export (String) var icon_name setget set_icon_name
export (String) var pressed_icon_name setget set_pressed_icon_name
export (NodePath) var linked_field

func _ready():
	if icon == null:
		set_icon_name(icon_name)

func set_icon_name(name: String):
	icon_name = name

	icon = AnimaUI.get_godot_icon(icon_name)

func set_pressed_icon_name(name: String):
	pressed_icon_name = name

func _on_GodotUIToolButton_pressed():
	var name: String = icon_name
	
	if pressed and pressed_icon_name:
		name = pressed_icon_name

	icon = AnimaUI.get_godot_icon(name)

func _on_GodotUIButton_visibility_changed():
	pass # Replace with function body.
