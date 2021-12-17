tool
extends GraphNode

signal disconnect_request(from, from_slot, to, to_slot)

var node_id: String
var node_category: String
var _node_type: int
var input_slots: Array = []
var output_slots: Array = []
var _connected_outputs: Array = []

var preview_panel: Panel = null;
var _custom_title: Control
var node_size_with_preview_panel_closed: Vector2

func setup() -> void:
	pass

# interface methods
func get_shader_global_code() -> String:
	return ""

func get_shader_code(output_port: int, inputs: Array) -> String:
	return ""

# node stuff
func connect_input(slot: int, from: Node, from_port: int) -> void:
	var row_container = find_node('Row' + str(slot), true, false)

	if row_container:
		row_container.set_connected(AnimaUI.PORT.INPUT)

func connect_output(slot: int, to_node: Node, to_port: int) -> void:
	var row_container = find_node('Row' + str(slot), true, false)

	if row_container:
		row_container.set_connected(AnimaUI.PORT.OUTPUT)

	var is_already_connected := false
	for index in range(0, _connected_outputs.size()):
		var connected_output = _connected_outputs[index]

		if connected_output[0] == slot and connected_output[1] == to_node and connected_output[2] == to_port:
			is_already_connected = true
			break

	if not is_already_connected:
		_connected_outputs.push_back([slot, to_node, to_port])
		
func get_connected_outputs() -> Array:
	return _connected_outputs

# node stuff
func disconnect_input(slot: int) -> void:
	var row_container = find_node('Row' + str(slot), true, false)

	if row_container:
		row_container.set_disconnected(AnimaUI.PORT.INPUT)

func disconnect_output(slot: int, to_node: Node, to_port: int) -> void:
	var row_container = find_node('Row' + str(slot), true, false)

	if row_container:
		row_container.set_disconnected(AnimaUI.PORT.OUTPUT)

	for output in _connected_outputs:
		if output[0] == slot and output[1] == to_node and output[2] == to_port:
			_connected_outputs.erase(output)

			break

func remove() -> void:
	emit_signal("close_request")

func disconnect_node(from: Node, from_slot: int, to_slot: int, message: String = '') -> void:
	if message.length() > 0:
		printerr(message)

	emit_signal("disconnect_request", from, from_slot, self, to_slot)
