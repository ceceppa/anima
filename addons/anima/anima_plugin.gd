@tool
extends EditorPlugin

func _init():
	randomize()

func get_name():
	return 'Anima'

func _enter_tree():
	add_autoload_singleton("ANIMA", 'res://addons/anima/core/constants.gd')

func _exit_tree():
	remove_autoload_singleton('ANIMA')
