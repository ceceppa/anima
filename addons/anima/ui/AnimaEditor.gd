tool
extends Control

signal switch_position
signal connections_updated(new_list)

const VISUAL_EDITOR_FADE_DURATION := 0.1

var _start_node: Node
var _anima_visual_node: Node
var _node_offset: Vector2
var _is_restoring_data := false

onready var _frames_editor: AnimaRectangle = find_node("FramesEditor")
onready var _nodes_window: WindowDialog = find_node("NodesWindow")
onready var _warning_label = find_node("WarningLabel")
onready var _animation_selector: OptionButton = find_node("AnimationSelector")
onready var _animation_speed: LineEdit = find_node("AnimationSpeed")

func _ready():
	$FramesEditor.hide()
#	_nodes_window.rect_min_size = Vector2(260, 320) * AnimaUI.get_dpi_scale()

func set_base_control(base_control: Control) -> void:
		AnimaUI.set_godot_gui(base_control)

func set_anima_node(node: Node) -> void:
	var is_node_different = _anima_visual_node != node
	_anima_visual_node = node

	if not is_node_different:
		return

	_maybe_show_graph_edit()

	if node == null:
		return

	_is_restoring_data = true
	_anima_visual_node = node

	var data = node.__anima_visual_editor_data
	var root_node: Node = node.get_root_node()

	_nodes_window.populate_nodes_list(root_node)
	$PropertiesWindow.populate(root_node)

	AnimaUI.debug(self, 'restoring visual editor data', data)

#	_frames_editor.restore_data(data)

	_is_restoring_data = false

func show() -> void:
	.show()

func _maybe_show_graph_edit() -> bool:
	var is_graph_edit_visible = _anima_visual_node != null
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node(_frames_editor).anima_fade_in()
	)
	anima.with(
		Anima.Node(_warning_label).anima_animation_frames({
			from = {
				opacity = 1,
				scale = Vector2.ONE,
			},
			to = {
				opacity = 0,
				scale = Vector2(1.6, 1.6)
			}
		})
	)

	if is_graph_edit_visible:
		_frames_editor.visible = true
		_warning_label.visible = true

		anima.play()
	elif _frames_editor.visible:
		_frames_editor.visible = true
		_warning_label.visible = true

		anima.play_backwards_with_speed(1.3)

	yield(anima, "animation_completed")

	if _frames_editor:
		_frames_editor.visible = is_graph_edit_visible
		_warning_label.visible = !is_graph_edit_visible
		_nodes_window.visible = false

	return is_graph_edit_visible

func _on_GraphEdit_hide_nodes_list():
	_nodes_window.hide()

func _on_NodesPopup_node_selected(node: Node, path: String):
	_nodes_window.hide()

	_frames_editor.add_animation_for(node, path)

#	_update_anima_node_data()

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
		connection_list = _frames_editor.get_connection_list(),
		scroll_offset = _frames_editor.get_scroll_ofs(),
		zoom = _frames_editor.get_zoom(),
	}

	for child in _frames_editor.get_children():
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

	data.animations = _frames_editor.get_animations()
	data.events_slots = _frames_editor.get_events_slots()
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
	_nodes_window.set_global_position(position)
	_nodes_window.show()

func _on_AnimaNodeEditor_hide_nodes_list():
	_nodes_window.hide()

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

func _on_FramesEditor_select_node():
#	_nodes_window.popup_centered()
	$PropertiesWindow.popup_centered()

func _on_PropertiesWindow_property_selected(property, property_type, node, node_name):
	_frames_editor.add_animation_for(node, node_name)
