@tool
extends EditorPlugin

enum EditorPosition { 
	BOTTOM,
	RIGHT
}

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')
	add_autoload_singleton("Anima", 'res://addons/anima/core/anima.gd')

func _exit_tree():
	remove_autoload_singleton('ANIMA')
	remove_autoload_singleton('Anima')

