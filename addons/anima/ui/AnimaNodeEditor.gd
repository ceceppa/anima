tool
extends GraphEdit

const ANIMA_START_NODE = preload("res://addons/anima/nodes/anima_node.gd")
const ANIMATION_NODE = preload("res://addons/anima/nodes/animation_node.gd")

signal node_connected
signal node_updated
signal show_nodes_list(offset, position)
signal hide_nodes_list

var _anima_start_node: GraphNode

func _init():
	self.connect('connection_request', self, '_on_connection_request')
	self.connect('disconnection_request', self, '_on_disconnection_request')

	set_right_disconnects(true)

func get_anima_start_node(source_node: Node, animations := [], events_slots := []) -> GraphNode:
	if _anima_start_node == null or not is_instance_valid(_anima_start_node):
		_anima_start_node = ANIMA_START_NODE.new()

		_anima_start_node.connect("node_updated", self, "_on_node_updated")

		_anima_start_node.set_offset(Vector2(get_rect().size.x - 300, 20))

	_anima_start_node.set_source_node(source_node)
	_anima_start_node.set_animations(animations)
	_anima_start_node.set_events_slots(events_slots)

	return _anima_start_node

func get_events_slots() -> Array:
	return _anima_start_node.get_events_slots()

func get_animations() -> Array:
	return _anima_start_node.get_animations()

func _on_connection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> bool:
	if from_node == to_node:
		return false

	for connection in get_connection_list():
		if connection["to"] == to_node and connection["to_port"] == to_slot:
			disconnect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])
			break

	connect_node(from_node, from_slot, to_node, to_slot)

	emit_signal("node_connected")

	return true

func connect_node(from_node: String, from_slot: int, to_node: String, to_slot: int) -> int:
	var from: Node
	var to: Node

	for child in get_children():
		if child.name == from_node:
			from = child
		elif child.name == to_node:
			to = child

	if from:
		from.connect_output(from_slot, to, to_slot)
	if to:
		to.connect_input(to_slot, from, from_slot)

	return .connect_node(from_node, from_slot, to_node, to_slot)

func get_connections() -> Array:
	var connections := [];

	for connection in get_connection_list():
		connections.push_back({
			'from': get_node(connection.from),
			'to': get_node(connection.to),
			'from_port': connection.from_port,
			'to_port': connection.to_port
		})

	return connections

func add_node(node_id: String, node_to_animate: Node, node_path: String, add_node := true) -> GraphNode:
	var node = ANIMATION_NODE.new()

	node.set_node_to_animate(node_to_animate, node_path)
	node.connect("node_updated", self, "_on_node_updated")
	node.connect("close_request", self, "_on_node_close_request", [node])
	node.connect("disconnect_request", self, "_on_disconnect_request")

	if add_node:
		add_child(node)

	return node

func _on_disconnection_request(from: String, from_port: int, to: String, to_port: int):
	disconnect_node(from, from_port, to, to_port)

func disconnect_node(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	var from: Node
	var to: Node

	for child in get_children():
		if child.name == from_node:
			from = child
		elif child.name == to_node:
			to = child

	if from:
		from.disconnect_output(from_port, to_node, to_port)

	if to:
		to.disconnect_input(to_port)

	.disconnect_node(from_node, from_port, to_node, to_port)

	emit_signal("node_updated")

func _on_node_updated():
	emit_signal('node_updated')

func _on_GraphEdit_gui_input(event):
	if event is InputEventMouseButton and event.pressed == true:
		if event.button_index == BUTTON_RIGHT:
			emit_signal("show_nodes_list", event.position + scroll_offset, event.global_position)
		else:
			emit_signal("hide_nodes_list")

func _on_node_close_request(node: GraphNode) -> void:
	for connection in get_connection_list():
		if connection.from == node.name or connection.to == node.name:
			_on_disconnection_request(connection.from, connection.from_port, connection.to, connection.to_port)

	node.queue_free()
	
	emit_signal("node_updated")

func _on_disconnect_request(from_node: Node, from_port: int, to_node: Node, to_port: int) -> void:
	var from: String = from_node.name
	var to: String = to_node.name

	for connection in get_connection_list():
		if connection.from == from and connection.from_port == from_port and connection.to == to and connection.to_port == to_port:
			disconnect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])

			break
