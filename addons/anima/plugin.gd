tool
extends EditorPlugin

var plugin

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

func _exit_tree():
	remove_autoload_singleton('Anima')
