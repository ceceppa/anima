tool
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

export (Type) var type setget set_type
export (float) var min_value = -999.90
export (float) var max_value = 999.99

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

		emit_signal("changed")
	else:
		text = _old_text

		set_cursor_position(text.length())

func get_value():
	if type == Type.STRING:
		return text

	var value := float(text)
	value = clamp(abs(value), min_value, max_value)

	if type == Type.INTEGER:
		return int(value)

	return value

func set_value(value: String) -> void:
	text = value

func set_type(new_type: int) -> void:
	type = new_type

	var regex: String = REG_EX[type]

	_regex.compile(regex)

	emit_signal("type_changed", new_type)

func get_type() -> int:
	return type
