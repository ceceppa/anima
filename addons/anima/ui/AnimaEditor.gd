tool
extends Control

signal switch_position
signal connections_updated(new_list)

const VISUAL_EDITOR_FADE_DURATION := 0.1

var _start_node: Node
var _anima_visual_node: Node
var _node_offset: Vector2
var _is_restoring_data := false

onready var _graph_edit: GraphEdit = find_node("AnimaNodeEditor")
onready var _nodes_popup: PopupPanel = find_node("NodesPopup")
onready var _warning_label = find_node("WarningLabel")
onready var _animation_selector: OptionButton = find_node("AnimationSelector")
onready var _animation_speed: LineEdit = find_node("AnimationSpeed")

func _ready():
	$NodesPopup.rect_min_size = Vector2(260, 320) * AnimaUI.get_dpi_scale()

func set_base_control(base_control: Control) -> void:
		AnimaUI.set_godot_gui(base_control)

func edit(node: Node) -> void:
	_is_restoring_data = true
	_anima_visual_node = node
	AnimaUI.set_selected_anima_visual_node(node)

	clear_all_nodes()

	var data = node.__anima_visual_editor_data
	AnimaUI.debug(self, 'restoring visual editor data', data)

	if data == null || not data.has('nodes') || data.nodes.size() == 0:
		_start_node = _graph_edit.get_anima_start_node(node, [], [])

		_graph_edit.add_child(_start_node)
	else:
		var animations := []

		if data.has("animations"):
			animations = data.animations

		_add_nodes(data.nodes, animations, data.events_slots)
		_connect_nodes(data.connection_list)

		_graph_edit.set_scroll_ofs(data.scroll_offset)
		_graph_edit.set_zoom(data.zoom)

	_is_restoring_data = false

func clear_all_nodes() -> void:
	for node in _graph_edit.get_children():
		if node is GraphNode:
			_graph_edit.remove_child(node)
			node.free()

func _add_nodes(nodes_data: Array, animations_names: Array, events_slots: Array) -> void:
	AnimaUI.debug(self, 'adding nodes: ', nodes_data.size())

	for node_data in nodes_data:
		AnimaUI.debug(self, "node_data", node_data)
		var node: GraphNode

		if node_data.id == 'AnimaNode':
			node = _graph_edit.get_anima_start_node(_anima_visual_node, animations_names, events_slots)
			_start_node = node
		else:
			var root = _anima_visual_node.get_source_node()

			if root == null:
				root = _anima_visual_node

			var node_path: String = node_data.node_path
			var node_to_animate: Node = root.get_node(node_path)

			AnimaUI.debug(self, 'set node to animate', node_path)
			node = _graph_edit.add_node(node_data.id, node_to_animate, node_path, false)

		if not node_data.has("name"):
			continue

		node.set_offset(node_data.position)
		node.name = node_data.name
		node.set_custom_title(node_data.title, node_data.name)
		node.restore_data(node_data.data)

		node.render()
		_graph_edit.add_child(node)

		AnimaUI.debug(self, "node added")

func _connect_nodes(connection_list: Array) -> void:
	AnimaUI.debug(self, "connecting nodes", connection_list)

	for connection in connection_list:
		AnimaUI.debug(self, "connecting node", connection)
		_graph_edit.connect_node(connection.from, connection.from_port, connection.to, connection.to_port)

func set_anima_node(node: Node) -> void:
	var should_animate = _anima_visual_node != node
	_anima_visual_node = node

	if should_animate:
		_maybe_show_graph_edit()

func show() -> void:
	.show()

func _maybe_show_graph_edit() -> bool:
	var is_graph_edit_visible = _anima_visual_node != null
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node(_graph_edit).anima_fade_in()
	)
	anima.with(
		Anima.Node(_warning_label).anima_fade_out()
	)
	anima.with(
		Anima.Node(_warning_label).anima_scale(Vector2(1.6, 1.6))
	)
	anima.with(
		Anima.Node($PlayerBox) \
			.anima_position_y(0.0) \
			.anima_from("-:size:y - 20")
	)
	anima.with(
		Anima.Group($PlayerBox/Controls/MarginContainer/PlayerControls, 0.01) \
			.anima_fade_in() \
			.anima_delay(0.3) \
			.anima_sequence_type(Anima.GRID.FROM_CENTER) \
			.anima_initial_value(0)
	)
	anima.also(
		Anima.Group($PlayerBox/Controls/MarginContainer/PlayerControls, 0.01) \
			.anima_scale(Vector2.ONE) \
			.anima_delay(0.3) \
			.anima_from(Vector2(0.2, 0.2)) \
			.anima_sequence_type(Anima.GRID.FROM_CENTER) \
			.anima_easing(Anima.EASING.EASE_IN_OUT_BACK) \
			.anima_pivot(Anima.PIVOT.CENTER)
	)

	if is_graph_edit_visible:
		_graph_edit.visible = true
		_warning_label.visible = true
		$PlayerBox.visible = true

		anima.play()
	elif _graph_edit.visible:
		_graph_edit.visible = true
		_warning_label.visible = true
		$PlayerBox.visible = true

		anima.play_backwards_with_speed(1.3)

	yield(anima, "animation_completed")

	if _graph_edit:
		_graph_edit.visible = is_graph_edit_visible
		$PlayerBox.visible = is_graph_edit_visible
		_warning_label.visible = !is_graph_edit_visible
		$NodesPopup.visible = false

	return is_graph_edit_visible

func _on_Right_pressed():
	emit_signal("switch_position")

func _on_AddButton_pressed():
	if _nodes_popup.visible:
		_nodes_popup.hide()
	else:
		_nodes_popup.show()

func _on_animaEditor_visibility_changed():
	if not visible:
		_nodes_popup.hide()

	_maybe_show_graph_edit()

func _on_GraphEdit_hide_nodes_list():
	_nodes_popup.hide()

func _on_NodesPopup_node_selected(node: Node, path: String):
	_nodes_popup.hide()

	var graph_node: GraphNode = _graph_edit.add_node('', node, path)
	graph_node.set_offset(_node_offset)

	_update_anima_node_data()

func _update_anima_node_data() -> void:
	# This method is also invoked when restoring the Visual Editor using the
	# AnimaNode data, and in this case we don't need to do anything here
	# or will lose some informations.
	if _is_restoring_data:
		return

	var data:= {
		nodes = [],
		animations = {},
		events_slots = [],
		connection_list = _graph_edit.get_connection_list(),
		scroll_offset = _graph_edit.get_scroll_ofs(),
		zoom = _graph_edit.get_zoom(),
	}

	for child in _graph_edit.get_children():
		if child == null or child.is_queued_for_deletion():
			continue

		if child is GraphNode:
			var node_path = null

			if child.has_method('get_node_to_animate_path'):
				node_path = child.get_node_to_animate_path()

			data.nodes.push_back({
				name = child.name,
				title = child.get_title(),
				position = child.get_offset(),
				node_path = node_path,
				id = child.get_id(),
				data = child.get_data()
			})

	data.animations = _graph_edit.get_animations()
	data.events_slots = _graph_edit.get_events_slots()
	data.data_by_animation = _get_data_from_connections(_start_node)

	AnimaUI.debug(self, 'updating visual editor data', data)

	emit_signal("connections_updated", data)

func _get_data_from_connections(node: Node, animation_id: int = -1, data := {}, start_time := 0.0) -> Dictionary:
	var anima_source = _anima_visual_node.get_source_node()

	for output in node.get_connected_outputs():
		var time: float = start_time
		var to: GraphNode = output[1]

		if to == null:
			continue

		var output_port: int = output[0]
		var to_data: Dictionary = to.get_data()
		var node_data: Dictionary = node.get_data()
		var duration: float = node_data.duration if node_data.has("duration") else 0.0
		var delay: float =  node_data.delay if node_data.has("delay") else 0.0

		if node.name.find("AnimaNode") == 0:
			animation_id = output_port

			data[animation_id] = []
		elif output_port == 0:
			time += duration

		time += delay

		var node_path: String = to.get_node_to_animate_path()
		var animation_data: Dictionary = { start_time = time, node_path = node_path, data = to_data }

		data[animation_id].push_back(animation_data)

		if animation_id >= 0:
			_get_data_from_connections(to, animation_id, data, time )

	return data

func _update_animations_list() -> void:
	if _is_restoring_data and _animation_selector.items.size() > 0:
		return

	_animation_selector.items.clear()

	var animations: Array = AnimaUI.get_selected_anima_visual_node().get_animations_list()
	for animation in animations:
		_animation_selector.add_item(animation.name)

func _on_AnimaNodeEditor_show_nodes_list(offset: Vector2, position: Vector2):
	_node_offset = offset
	_nodes_popup.set_global_position(position)
	_nodes_popup.show()

func _on_AnimaNodeEditor_hide_nodes_list():
	_nodes_popup.hide()

func _on_AnimaNodeEditor_node_connected():
	_update_anima_node_data()

func _on_AnimaNodeEditor_node_updated():
	_update_anima_node_data()
	_update_animations_list()

func _on_PlayAnimation_pressed():
	var visual_node: Node = AnimaUI.get_selected_anima_visual_node()
	var animation_id: int = _animation_selector.get_selected_id()
	var name: String = _animation_selector.get_item_text(animation_id)
	var speed = float(_animation_speed.text)

#	var all_data = _get_data_from_connections(_start_node)
#	var data: Array = all_data[animation_id]
#	var anima: AnimaNode = Anima.begin(self)
#
#	for animation in data:
#		var animation_data: Dictionary = animation.data.animation_data
#		var node: Node = $AnimaNodeEditor.find_node(animation.node_path, true, false)
#
#		animation_data.property.on_started = [funcref(self, "_on_animation_started"), [node]]
#		animation_data.property.on_completed = [funcref(self, "_on_node_animation_completed"), [node]]
#
#		anima.with({ node = node, property = "opacity", duration = VISUAL_EDITOR_FADE_DURATION, to = 0.3 })
#		anima.with({ node = node, property = "scale", duration = VISUAL_EDITOR_FADE_DURATION, from = Vector2(1, 1), to = Vector2(0.8, 0.8) })

#	anima.play()
#	yield(anima, "animation_completed")

	visual_node.play_animation(name, speed, true)

	yield(visual_node, "animation_completed")
	
#	anima.play_backwards()
#	anima.queue_free()

func _on_animation_started(node: Node) -> void:
	if node == null:
		printerr("_on_animation_started: Node not found")

	var anima: AnimaNode = Anima.begin_single_shot(node)
	anima.then(
		Anima.Node(node).anima_fade_in(VISUAL_EDITOR_FADE_DURATION)
	)
	anima.with(
		Anima.Node(node).anima_scale(Vector2.ONE)
	)

	anima.play()

func _on_node_animation_completed(node: Node) -> void:
	if node == null:
		printerr("_on_node_animation_completed: Node not found")

	var anima: AnimaNode = Anima.begin_single_shot(node)
	anima.then(
		Anima.Node(node).anima_property("opacity", 0.3, VISUAL_EDITOR_FADE_DURATION)
	)
	anima.with(
		Anima.Node(node).anima_scale(Vector2(0.8, 0.8), VISUAL_EDITOR_FADE_DURATION)
	)

	anima.play()

func _on_StopAnimation_pressed():
	var visual_node: AnimaVisualNode = AnimaUI.get_selected_anima_visual_node()

	visual_node.stop()
