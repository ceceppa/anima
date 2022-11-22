extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

export (String) var scene = ''

func _ready():
	connect("pressed", self, "_on_ButtonAnimations_pressed")

func _on_ButtonAnimations_pressed():
	printt("Loading new scene", scene)
	get_tree().change_scene(scene)
