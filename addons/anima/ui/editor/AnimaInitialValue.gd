tool
extends AnimaAccordion

onready var _property_label: Label = find_node("PropertyLabel")
onready var _property_value = find_node("PropertyValue")

func _ready():
	_property_value.set_value("")

func add_for(node: Node, path: String, property_name: String, property_type) -> void:
	if path == ".":
		path = "(root)"

	set_label(path + " : " + property_name)

	if _property_label == null:
		_property_label = find_node("PropertyLabel")
		_property_value = find_node("PropertyValue")

	_property_label.set_text(property_name)
	_property_value.set_type(property_type)

func _on_Delete_pressed():
	queue_free()
