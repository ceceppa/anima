extends Button
@export var scene: String = ''

func _ready():
	connect("pressed",Callable(self,"_on_ButtonAnimations_pressed"))

func _on_ButtonAnimations_pressed():
	get_tree().change_scene_to_file(scene)
