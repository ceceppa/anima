@tool
extends Control

signal switch_position
signal connections_updated(new_list)
signal visual_builder_updated
signal highlight_node(node)
signal play_animation(animation_info)
signal change_editor_position(new_position)

@onready var _frames_editor: Control = find_child("FramesEditor")
@onready var _nodes_window: Window = find_child("NodesWindow")
@onready var _warning_label = find_child("WarningLabel")
@onready var _animation_selector: OptionButton = find_child("AnimationSelector")
@onready var _animation_speed: LineEdit = find_child("AnimationSpeed")

const VISUAL_EDITOR_FADE_DURATION := 0.1

enum PROPERTY_SELECTED_ACTION {
	ADD_NEW_ANIMATION,
	UPDATE_ANIMATION
}

var _anima_visual_node: Node
var _anima_visual_node_path
var _node_offset: Vector2
var _is_restoring_data := false
var _scene_root_node: Node
var _animation_source_node: Node
var _is_selecting_relative_property := false
var _on_property_selected_action: int = PROPERTY_SELECTED_ACTION.ADD_NEW_ANIMATION
var _source_animation_data_node: Node
var _current_animation := "0"
var _flow_direction := 0

func _ready():
	_frames_editor.hide()

func set_anima_node(node: Node) -> void:
	if node and not node.is_inside_tree():
		return

	var node_path = node.get_path() if node else ""
	var is_node_different = _anima_visual_node_path != node_path
	_anima_visual_node = node

	if not is_node_different:
		return

	_maybe_show_graph_edit()

	if node == null:
		_anima_visual_node_path = ""
		return

	_anima_visual_node_path = node.get_path()

	if not node.is_connected("tree_exited",Callable(self,"_on_anima_visual_node_deleted")):
		node.connect("tree_exited",Callable(self,"_on_anima_visual_node_deleted"))

	_anima_visual_node = node

	_restore_visual_editor_data()

func _restore_visual_editor_data() -> void:
	_is_restoring_data = true

	var data = _anima_visual_node.__anima_visual_editor_data
	_scene_root_node = _anima_visual_node.get_root_node()

	_nodes_window.populate_nodes_list(_scene_root_node)
	$PropertiesWindow.populate(_scene_root_node)

	_restore_data(data)

	_is_restoring_data = false

func show() -> void:
	super.show()

func update_flow_direction(new_direction: int) -> void:
	_flow_direction = new_direction
	$FramesEditor.update_flow_direction(new_direction)

	if _flow_direction == 0:
		minimum_size.y = 420

func _maybe_show_graph_edit() -> bool:
	var is_graph_edit_visible = _anima_visual_node != null

	if _frames_editor == null:
		return

#	if _flow_direction == 1:
	visible = is_graph_edit_visible
	_frames_editor.show()
	_warning_label.hide()

	return is_graph_edit_visible

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

	await anima.animation_completed

	if _frames_editor:
		_frames_editor.visible = is_graph_edit_visible
		_warning_label.visible = !is_graph_edit_visible
		_nodes_window.visible = false

	return is_graph_edit_visible

func _restore_data(data: Dictionary) -> void:
	if not data.has(_current_animation):
		_frames_editor.clear()

		return

	var animation = data[_current_animation]
	
	_frames_editor.clear()
	_frames_editor.set_is_restoring_data(true)

	_frames_editor.restore_animation_data(animation.animation)

	var key_index := 0
	var total_frames = animation.frames.keys().size() - 1

	for frame_key in animation.frames:
		var frame_data = animation.frames[frame_key]
		var index: int = int(frame_key)

		if frame_data == null:
			continue

		if frame_data.type == "frame":
			_frames_editor._on_AnimaAddFrame_add_frame(frame_key)
		elif frame_data.type == "delay":
			_frames_editor._on_AnimaAddFrame_add_delay(frame_key)
		else:
			pass

		var the_frame = _frames_editor.select_frame(frame_key)
		var frame_name: String = frame_data.name if frame_data.has("name") and frame_data.name else "Frame " + str(index)

		if not the_frame.is_connected("move_one_left",Callable(self,"_on_frame_move_one_left")):
			the_frame.connect("move_one_left",Callable(self,"_on_frame_move_one_left").bind(key_index))
			the_frame.connect("move_one_right",Callable(self,"_on_frame_move_one_right").bind(key_index))

		_frames_editor.set_frame_name(frame_name)

		if frame_data.has("duration") and frame_data.duration != null:
			_frames_editor.set_frame_duration(frame_data.duration)

		if not frame_data.has("data"):
			frame_data.data = {}

		the_frame.set_has_previous(key_index > 0)
		the_frame.set_has_next(key_index < total_frames)
		the_frame.set_meta("_data_index", key_index)

		for data_index in frame_data.data.size():
			var value = frame_data.data[data_index]

			if value is String:
				if the_frame.has_method("restore_data"):
					the_frame.restore_data(frame_data.data)
				
				continue

			if value and value.has("node_path"):
				if _anima_visual_node == null:
					_frames_editor.clear()

					break

				var node: Node = _anima_visual_node.get_root_node().get_node(value.node_path)
				
				await get_tree().idle_frame

				var item: Node = _add_animation_for(node, value.node_path)

				item.set_meta("_data_index", data_index)
				item.restore_data(value)

		# TODO: Restore collapse
		if frame_data.has("collapsed") and frame_data.collapsed:
			the_frame.collapse()

		key_index += 1

	_frames_editor.set_is_restoring_data(false)

func _add_animation_for(node: Node, node_path: String) -> Node:
	var item: Node = _frames_editor.add_animation_for(node, node_path)

	item.connect("select_animation",Callable(self,"_on_select_animation").bind(item))
	item.connect("select_relative_property",Callable(self,"_on_select_relative_property").bind(item))
	item.connect("select_easing",Callable(self,"_on_select_easing").bind(item))
	item.set_meta("_data_index", item.get_index() - 1)

	return item

func _on_GraphEdit_hide_nodes_list():
	_nodes_window.hide()

func _on_NodesPopup_node_selected(node: Node, path: String):
	_nodes_window.hide()

func _on_AnimaNodeEditor_show_nodes_list(offset: Vector2, position: Vector2):
	_node_offset = offset
	_nodes_window.set_global_position(position)
	_nodes_window.show()

func _on_AnimaNodeEditor_hide_nodes_list():
	_nodes_window.hide()

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
	var visual_node: AnimaVisualNode = null

	visual_node.stop()

func _on_FramesEditor_select_node():
	$NodesWindow.popup_centered()

func _on_PropertiesWindow_property_selected(node_path, property, property_type):
	var node: Node = _anima_visual_node.get_root_node().get_node(node_path)

	if _is_selecting_relative_property:
		_animation_source_node.set_relative_property(node_path, property)
	elif _on_property_selected_action == PROPERTY_SELECTED_ACTION.ADD_NEW_ANIMATION:
		_frames_editor.add_animation_for(node, node_path, property, property_type)
	else:
		_source_animation_data_node.set_property_to_animate(property, property_type)

	_is_selecting_relative_property = false

func _on_FramesEditor_visual_builder_updated(data):
	if not _is_restoring_data:
		emit_signal("visual_builder_updated", data)

func _on_anima_visual_node_deleted() -> void:
	_anima_visual_node = null

	_maybe_show_graph_edit()

func _on_FramesEditor_highlight_node(node: Node):
	emit_signal("highlight_node", node)

func _on_select_animation(source: Node) -> void:
	_animation_source_node = source

	$AnimationsWindow.show_demo_by_type(source)
	$AnimationsWindow.popup_centered()

func _on_AnimationsWindow_animation_selected(label, name):
	_animation_source_node.selected_animation(label, name)

func _on_select_relative_property(source: Node) -> void:
	_animation_source_node = source

	_is_selecting_relative_property = true

	$PropertiesWindow.window_title = "Select the relative property source"
	$PropertiesWindow._nodes_list.show()

	$PropertiesWindow.popup_centered()

func _on_select_easing(source: Node) -> void:
	_animation_source_node = source

	$AnimaEasingsWindow.popup_centered()

func _on_AnimaEasingsWindow_easing_selected(easing_name: String, easing_value: int):
	_animation_source_node.set_easing(easing_name, easing_value)

func _on_FramesEditor_select_node_property(source: Node, node_path: String):
	_on_property_selected_action = PROPERTY_SELECTED_ACTION.UPDATE_ANIMATION
	_source_animation_data_node = source

	var node = get_node(node_path)

	$PropertiesWindow.select_node(node)

	$PropertiesWindow.window_title = "Select the node property to animate"
	$PropertiesWindow.popup_centered()

func _on_FramesEditor_add_node(node_path):
	var node = get_node(node_path)

	# The node_path needs to be relative to the AnimaVlisualNode
	var relative_node_path = _anima_visual_node.get_root_node().get_path_to(node)

	_add_animation_for(node, relative_node_path)

func _on_FramesEditor_select_animation():
	pass # Replace with function body.

func _on_frame_move_one_left(frame_index: int) -> void:
	_swap_frames(frame_index, frame_index - 1)

func _on_frame_move_one_right(frame_index: int) -> void:
	_swap_frames(frame_index, frame_index + 1)

func _swap_frames(from: int, to: int) -> void:
	var data = _anima_visual_node.__anima_visual_editor_data
	var temp = data[_current_animation].frames[from]

	data[_current_animation].frames[from] = data[_current_animation].frames[to]
	data[_current_animation].frames[to] = temp

	_on_FramesEditor_visual_builder_updated(data)

	_restore_data(data)

func _on_FramesEditor_preview_animation(preview_info):
	if not preview_info.has("animation_name"):
		preview_info.animation_name = _frames_editor.get_selected_animation_name()

	_anima_visual_node.preview_animation(preview_info)

func refresh() -> void:
	_restore_visual_editor_data()

func _on_FramesEditor_change_editor_position(new_position):
	emit_signal("change_editor_position", new_position)
