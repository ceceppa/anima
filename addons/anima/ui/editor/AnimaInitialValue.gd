tool
extends AnimaAccordion

signal updated

onready var _property_label: Label = find_node("PropertyLabel")
onready var _property_value = find_node("PropertyValue")

var _node_path: String
var _property_name: String
var _property_type

func _ready():
	_property_value.set_value("")

func add_for(node: Node, node_path: String, property_name: String, property_type) -> void:
	var path := node_path

	if path == ".":
		path = "(root)"

	set_label(path + " : " + property_name)

	if _property_label == null:
		_property_label = find_node("PropertyLabel")
		_property_value = find_node("PropertyValue")

	_property_label.set_text(property_name)
	_property_value.set_type(property_type)

	_node_path = node_path
	_property_name = property_name
	_property_type = property_type

func get_data() -> Dictionary:
	return {
		type = "initial",
		value = _property_value.get_value(),
		node_path = _node_path,
		property_name = _property_name,
		property_type = _property_type
	}

func set_value(value) -> void:
	_property_value.set_value(value)

	set_expanded(false, false)

func _on_Delete_pressed():
	queue_free()
	emit_signal("updated")

func _on_PropertyValue_vale_updated():
	emit_signal("updated")
