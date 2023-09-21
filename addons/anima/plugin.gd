@tool
extends EditorPlugin

var _anima_inspector_plugin := preload("res://addons/anima/components/anima_animated_control_inspector.gd").new(self)

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

	add_inspector_plugin(_anima_inspector_plugin)

func _exit_tree():
	remove_autoload_singleton('ANIMA')
	remove_autoload_singleton('Anima')
	
	remove_inspector_plugin(_anima_inspector_plugin)

