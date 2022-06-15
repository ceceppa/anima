tool
extends Control

signal switch_position
signal connections_updated(new_list)
signal visual_builder_updated

const VISUAL_EDITOR_FADE_DURATION := 0.1

var _anima_visual_node: Node
var _node_offset: Vector2
var _is_restoring_data := false
var _scene_root_node: Node

onready var _frames_editor: Control = find_node("FramesEditor")
onready var _nodes_window: WindowDialog = find_node("NodesWindow")
onready var _warning_label = find_node("WarningLabel")
onready var _animation_selector: OptionButton = find_node("AnimationSelector")
onready var _animation_speed: LineEdit = find_node("AnimationSpeed")

func _ready():
	_frames_editor.hide()

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
	_scene_root_node = node.get_root_node()

	_nodes_window.populate_nodes_list(_scene_root_node)
	$PropertiesWindow.populate(_scene_root_node)

	AnimaUI.debug(self, 'restoring visual editor data', data)

	_restore_data(data)

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

func _restore_data(data: Dictionary) -> void:
	if not data.has("0"):
		return

	var animation = data["0"]
	
	_frames_editor.clear()
	_frames_editor.set_is_restoring_data(true)

	_frames_editor.restore_animation_data(animation.animation)

	for frame_key in animation.frames:
		var frame_data = animation.frames[frame_key]
		var index: int = int(frame_key)

		if frame_data == null:
			continue

		if frame_data.type == "frame":
			_frames_editor._on_AnimaAddFrame_add_frame()
		elif frame_data.type == "delay":
			_frames_editor._on_AnimaAddFrame_add_delay()
		else:
			pass

		_frames_editor.select_frame(index)

		var frame_name: String = frame_data.name if frame_data.has("name") and frame_data.name else "Frame " + str(index)

		_frames_editor.set_frame_name(frame_name)

		if frame_data.duration:
			_frames_editor.set_frame_duration(frame_data.duration)

		for value in frame_data.data:
			if value.has("node_path"):
				var node: Node = _scene_root_node.get_node(value.node_path)

				var item: Node = _frames_editor.add_animation_for(node, value.node_path, value.property_name, value.property_type)
				item.set_value(value.value)

	_frames_editor.set_is_restoring_data(false)

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

func _on_PropertiesWindow_property_selected(node_path, property, property_type):
	var node: Node = _anima_visual_node.get_root_node().get_node(node_path)

	_frames_editor.add_animation_for(node, node_path, property, property_type)

func _on_FramesEditor_visual_builder_updated(data):
	if not _is_restoring_data:
		emit_signal("visual_builder_updated", data)
