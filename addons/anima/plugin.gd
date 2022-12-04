@tool
extends EditorPlugin

enum EditorPosition { 
	BOTTOM,
	RIGHT
}

var _anima_editor
var _anima_editor_2d_right
var _anima_editor_3d_right
var _anima_visual_node: Node
var _current_position = EditorPosition.BOTTOM
var _active_anima_editor

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

	_anima_editor = _load_anima_editor(0)
	_anima_editor.update_flow_direction(0)

	_anima_editor_2d_right = _load_anima_editor(1)
	_anima_editor_2d_right.name = "AnimaVisualEditor2D"
	_anima_editor_2d_right.update_flow_direction(1)

	_anima_editor_3d_right = _load_anima_editor(2)
	_anima_editor_3d_right.name = "AnimaVisualEditor3D"
	_anima_editor_3d_right.update_flow_direction(1)

	_anima_editor.hide()
	_anima_editor_2d_right.hide()
	_anima_editor_3d_right.hide()

	_active_anima_editor = _anima_editor

func _load_anima_editor(position: int):
	var editor = load("res://addons/anima/visual-editor/AnimaVisualEditor.tscn").instantiate()

	editor.connect("switch_position",Callable(self,"_on_anima_editor_switch_position"))
	editor.connect("visual_builder_updated",Callable(self,'_on_visual_builder_updated'))
	editor.connect("highlight_node",Callable(self,'_on_highlight_node'))
	editor.connect("play_animation",Callable(self,'_on_play_animation'))
	editor.connect("change_editor_position",Callable(self,'_on_change_editor_position'))

	_add_anima_editor(editor, position)

	return editor

func _exit_tree():
	_remove_anima_editor()

	remove_autoload_singleton('ANIMA')
	remove_autoload_singleton('Anima')

	if _anima_editor:
		_anima_editor.queue_free()
		_anima_editor_2d_right.queue_free()

func _add_anima_editor(editor: Node, where: int) -> void:
	if where == 0:
		add_control_to_bottom_panel(editor, "Anima Animation Builder")
	elif where == 1:
		add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, editor)
	else:
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, editor)

func _remove_anima_editor() -> void:
	remove_control_from_bottom_panel(_anima_editor)
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, _anima_editor_2d_right)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, _anima_editor_3d_right)

func handles(object):
	var is_anima_node = object.has_meta("__anima_visual_node")
	var root: Node

	if not object is Node:
		return

	if not is_anima_node and object is Node:
		root = object

		while root.get_parent():
			var parent = root.get_parent()

			if parent is SubViewport:
				break

			root = parent

	if root:
		object = root.find_child("AnimaVisualNode", false)

		if object:
			is_anima_node = true

	#
	# We need to defer this call for when we open a project as the user might have
	# multiple tabs open and this causes this function to be triggered for each
	# of them, causing some restoring data to be stopped while running.
	# Causing funny results
	#
	if _anima_visual_node != object:
		call_deferred("set_anima_node", is_anima_node, object)

	return is_anima_node

func set_anima_node(is_anima_node: bool, object) -> void:

	if is_anima_node and object and _anima_visual_node != object:
		var old_active_editor = _active_anima_editor

		_anima_visual_node = object

		_on_editor_position_changed(_anima_visual_node._editor_position)

		_active_anima_editor.set_anima_node(object)
		_active_anima_editor.show()

		if old_active_editor != _active_anima_editor:
			old_active_editor.hide()
	elif not is_anima_node:
		_active_anima_editor.set_anima_node(null)

		_anima_visual_node = null

	if _anima_visual_node and not _anima_visual_node.is_connected("on_editor_position_changed",Callable(self,"_on_editor_position_changed")):
		_anima_visual_node.connect("on_editor_position_changed",Callable(self,"_on_editor_position_changed"))

		_on_editor_position_changed(_anima_visual_node._editor_position)

func _on_editor_position_changed(new_position: int) -> void:
	_anima_editor.hide()
	_anima_editor_2d_right.hide()

	if new_position == 0:
		_active_anima_editor = _anima_editor
	else:
		if _anima_visual_node.get_root_node() is Node3D:
			_active_anima_editor = _anima_editor_3d_right
		else:
			_active_anima_editor = _anima_editor_2d_right

	_active_anima_editor.set_anima_node(_anima_visual_node)
	_active_anima_editor.show()

func _on_visual_builder_updated(data: Dictionary) -> void:
	if not _anima_visual_node:
		return

	var current_data: Dictionary = _anima_visual_node.__anima_visual_editor_data
	var undo_redo = get_undo_redo() # Method of EditorPlugin.

	undo_redo.create_action('Updated AnimaVisualNode')
	undo_redo.add_do_property(_anima_visual_node, "__anima_visual_editor_data", data)
	undo_redo.add_undo_method(self, "_undo_visual_editor_data", current_data)
	undo_redo.commit_action()

func _on_highlight_node(node_to_highlight: Node) -> void:
	var selection := get_editor_interface().get_selection()
	var nodes := selection.get_selected_nodes()

	if nodes.size() == 1 and nodes[0] == node_to_highlight:
		return

	selection.clear()
	selection.add_node(node_to_highlight)

func _undo_visual_editor_data(previous_data) -> void:
	_anima_visual_node.__anima_visual_editor_data = previous_data

	_active_anima_editor.refresh()

func _on_change_editor_position(new_position) -> void:
	if _anima_visual_node:
		_anima_visual_node._editor_position = new_position
