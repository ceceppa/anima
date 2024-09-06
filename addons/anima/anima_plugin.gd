@tool
extends EditorPlugin

var _anima_inspector_plugin := preload("res://addons/anima/components/anima_animated_control_inspector.gd").new(self)

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')

	add_inspector_plugin(_anima_inspector_plugin)

func _exit_tree():
	remove_autoload_singleton('ANIMA')
	
	remove_inspector_plugin(_anima_inspector_plugin)

func _update_animated_events(node: Node, current_data: Array[Dictionary], events: Array[Dictionary]):
	var undo_redo = get_undo_redo()

	undo_redo.create_action('Updated Anima Control Events')
	undo_redo.add_do_property(node, "__events", events)
	undo_redo.add_undo_method(self, "_undo_update_animated_events", node, current_data)
	undo_redo.commit_action()

func _undo_update_animated_events(node: Node, previous_data):
	node._animatable.set_animated_events(previous_data)

	_anima_inspector_plugin.refresh_event_items()
