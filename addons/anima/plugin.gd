tool
extends EditorPlugin

enum EditorPosition { 
	BOTTOM,
	RIGHT
}

var _anima_editor
var _anima_visual_node: Node
var _current_position = EditorPosition.BOTTOM

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("AnimaUI", 'res://addons/anima/ui/AnimaUI.gd')
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

	_anima_editor = load("res://addons/anima/ui/AnimaEditor.tscn").instance()
	_anima_editor.connect("switch_position", self, "_on_anima_editor_switch_position")
	_anima_editor.connect("visual_builder_updated", self, '_on_visual_builder_updated')
	_anima_editor.set_base_control(get_editor_interface().get_base_control())

	add_control_to_bottom_panel(_anima_editor, "Anima")

func _exit_tree():
	remove_autoload_singleton('AnimaUI')
	remove_autoload_singleton('Anima')
	remove_control_from_bottom_panel(_anima_editor)

	if _anima_editor:
		_anima_editor.queue_free()

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

	return is_anima_node

func _on_anima_editor_switch_position() -> void:
	if _current_position == EditorPosition.BOTTOM:
		remove_control_from_bottom_panel(_anima_editor)
		add_control_to_container(
			EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, 
			_anima_editor
		)
		_current_position = EditorPosition.RIGHT
	else:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, _anima_editor)
		add_control_to_bottom_panel(_anima_editor, "Anima")
		_current_position = EditorPosition.BOTTOM

	_anima_editor.show()

func _on_visual_builder_updated(data: Dictionary) -> void:
	var current_data: Dictionary = _anima_visual_node.__anima_visual_editor_data
	var undo_redo = get_undo_redo() # Method of EditorPlugin.

	undo_redo.create_action('Updated AnimaVisualNode')
#	undo_redo.add_do_method(self, "_do_update_anima_node")
#	undo_redo.add_undo_method(self, "_do_update_anima_node")
	undo_redo.add_do_property(_anima_visual_node, "__anima_visual_editor_data", data)
	undo_redo.add_undo_property(_anima_visual_node, "__anima_visual_editor_data", current_data)
	undo_redo.commit_action()
