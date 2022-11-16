tool
extends EditorPlugin

enum EditorPosition { 
	BOTTOM,
	RIGHT
}

var _anima_editor
var _anima_visual_node: Node
var _current_position = EditorPosition.BOTTOM

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

	_anima_editor = load("res://addons/anima/visual-editor/AnimaVisualEditor.tscn").instance()
#	_anima_editor.connect("switch_position", self, "_on_anima_editor_switch_position")
	_anima_editor.connect("visual_builder_updated", self, '_on_visual_builder_updated')
	_anima_editor.connect("highlight_node", self, '_on_highlight_node')
	_anima_editor.connect("play_animation", self, '_on_play_animation')

	_add_anima_editor(0)

func _exit_tree():
	_remove_anima_editor()

	remove_autoload_singleton('ANIMA')
	remove_autoload_singleton('Anima')

	if _anima_editor:
		_anima_editor.queue_free()

func _add_anima_editor(where: int) -> void:
	if where == 0:
		add_control_to_bottom_panel(_anima_editor, "Anima Animation Builder")
	elif where == 1:
		add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, _anima_editor)
	else:
		add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _anima_editor)

func _remove_anima_editor() -> void:
	remove_control_from_bottom_panel(_anima_editor)
#	remove_control_from_docks(_anima_editor)
#	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, _anima_editor)

func handles(object):
	var is_anima_node = object.has_meta("__anima_visual_node")
	var root: Node

	if not object is Node:
		return

	if not is_anima_node and object is Node:
		root = object

		while root.get_parent():
			var parent = root.get_parent()

			if parent is Viewport:
				break

			root = parent

	if root:
		object = root.find_node("AnimaVisualNode", false)

		if object:
			is_anima_node = true

	if is_anima_node and object and _anima_visual_node != object:
		_anima_editor.set_anima_node(object)

		_anima_visual_node = object
	elif not is_anima_node:
		_anima_editor.set_anima_node(null)

		_anima_visual_node = null

	if _anima_visual_node and not _anima_visual_node.is_connected("on_editor_position_changed", self, "_on_editor_position_changed"):
		_anima_visual_node.connect("on_editor_position_changed", self, "_on_editor_position_changed")

		_on_editor_position_changed(_anima_visual_node._editor_position)

	return is_anima_node

func _on_editor_position_changed(new_position: int) -> void:
	return
	_remove_anima_editor()

	_anima_editor.update_flow_direction(new_position)

	_add_anima_editor(new_position)


func _on_visual_builder_updated(data: Dictionary) -> void:
	var current_data: Dictionary = _anima_visual_node.__anima_visual_editor_data
	var undo_redo = get_undo_redo() # Method of EditorPlugin.

	undo_redo.create_action('Updated AnimaVisualNode')
#	undo_redo.add_do_method(self, "_do_update_anima_node")
#	undo_redo.add_undo_method(self, "_do_update_anima_node")
	undo_redo.add_do_property(_anima_visual_node, "__anima_visual_editor_data", data)
	undo_redo.add_undo_property(_anima_visual_node, "__anima_visual_editor_data", current_data)
	undo_redo.commit_action()

func _on_highlight_node(node_to_highlight: Node) -> void:
	var selection := get_editor_interface().get_selection()
	
	selection.clear()
	selection.add_node(node_to_highlight)

func _on_play_animation(name: String) -> void:
	_anima_visual_node.play_animation(name, 1.0, true)
