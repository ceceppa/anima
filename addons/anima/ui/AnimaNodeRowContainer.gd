tool
extends PanelContainer

var labels := []

func _ready():
	# The nodes are "renamed", so we can't access to Label1, Label2
	for child in $HBoxContainer.get_children():
		if child.is_class('Label'):
			labels.push_back(child)

			_set_disconnected_color(child)

func set_connected(index: int):
	var child = labels[index]

	_set_connected_color(child)

func set_disconnected(index: int):
	var child = labels[index]

	_set_disconnected_color(child)

func disconnect_all():
	set_disconnected(AnimaUI.PORT.INPUT)
	set_disconnected(AnimaUI.PORT.OUTPUT)

func hide_default_input_container():
	$HBoxContainer/DefaultInputContainer.hide()

func _set_connected_color(label: Node):
	label.add_color_override("font_color", AnimaUI.CONNECTED_LABEL_COLOR)
	
func _set_disconnected_color(label: Node):
	label.add_color_override("font_color", AnimaUI.DISCONNECTED_LABEL_COLOR)
