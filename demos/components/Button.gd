extends Button

export (String) var scene = ''

func _on_ButtonAnimations_pressed():
	printt("Loading new scene", scene)
	get_tree().change_scene(scene)
