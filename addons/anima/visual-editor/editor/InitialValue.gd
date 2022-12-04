@tool
extends MarginContainer

@onready var value = find_child("Value")

signal updated
signal removed

var _path: String
var _property

func _ready():
	value.set_show_relative_selector(false)

func set_data(node: Node, path: String, property, property_type: int) -> void:
	var label: Label = find_child("Label")

	if value == null:
		value = find_child("Value")

	label.text = node.name + ":" + property

	value.set_type(property_type)

	var v = AnimaNodesProperties.get_property_value(node, {}, property)
	value.set_value(v)

	_path = path
	_property = property

func get_data() -> Dictionary:
	var v = value.get_value()

	return {
		node_path = _path,
		property_name = _property,
		property_type = value.type,
		value = v
	}

func set_value(the_value) -> void:
	value.set_value(the_value)
	
	# I have no idea isn't hidden in first place
	value.find_child("RelativeSelectorButton").hide()

func _on_PropertyFromTo_value_updated():
	emit_signal("updated")

func _on_AnimaButton_pressed():
	emit_signal("removed", self)
