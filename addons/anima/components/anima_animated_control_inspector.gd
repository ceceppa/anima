@tool
extends EditorInspectorPlugin

var _animation_picker := preload("res://addons/anima/ui/AnimationPicker.tscn").instantiate()
var _parent: EditorPlugin

func _init(parent: EditorPlugin):
	_parent = parent
	
	_animation_picker.hide()
	_parent.add_child(_animation_picker)

func _can_handle(object):
	return object.has_method("is_anima_animated_control")

func _parse_begin(object):
	if object.has_method('is_anima_animated_control'):
		var button := Button.new()
		button.text = "Add event"
		button.pressed.connect(_on_add_event_pressed)

		add_custom_control(button)

func _on_add_event_pressed():
	_animation_picker.show()
	prints("ciao", _animation_picker.visible, _animation_picker.position, _animation_picker.size)
