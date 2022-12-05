@tool
extends LineEdit

signal changed
signal type_changed(new_type)

enum Type {
	INTEGER,
	FLOAT,
	STRING
}

const REG_EX = {
	Type.INTEGER: "^[+-]?[0-9]*$",
	Type.FLOAT: "^[+-]?([0-9]*([.][0-9]*)?|[.][0-9]+)$",
	Type.STRING: ".*",
}

@export var type: Type :
	get:
		return type # TODOConverter40 Non existent get function 
	set(new_type):
		type = new_type

		var regex: String = REG_EX[type]

		_regex.compile(regex)

		emit_signal("type_changed", type)

@export var min_value := -999.90
@export var max_value := 999.99

var _regex := RegEx.new()

var _old_text: String

func _ready():
	var regex: String = REG_EX[type]

	_regex.compile(regex)

func _on_NumberEdit_text_changed(new_text: String):
	# The regex validates the -/+ sign correctly but will
	# not allow to them to be the only value in the field, but we need to accept them
	var is_valid = _regex.search(new_text) or \
		new_text == '' or \
		['+', '-'].find(new_text) == 0

	if is_valid:
		_old_text = new_text

	else:
		text = _old_text

		set_caret_column(text.length())

func get_value():
	if type == Type.STRING:
		return text

	var value := text.to_float()
	value = clamp(abs(value), min_value, max_value)

	if type == Type.INTEGER:
		return int(value)

	return value

func set_value(value) -> void:
	text = str(value)

func get_type() -> int:
	return type

func _on_NumberEdit_type_changed(new_type):
	if new_type != Type.STRING:
		alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _on_NumberEdit_gui_input(event):
	if event is InputEventKey and event.scancode == KEY_ENTER and event.button_pressed == false:
		emit_signal("changed")
