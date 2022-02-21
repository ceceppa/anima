extends Spatial

func _ready():
	var animations = Anima.get_available_animation_by_category()

	for group in animations:
		$HBoxContainer/MenuButton.items.append("group")

		for animation in animations[group]:
			$HBoxContainer/MenuButton.items.append(animation)

func _on_Button_pressed():
	var anima: AnimaNode = Anima.begin_single_shot(self)
	
	anima.then({ node = $MeshInstance2, animation = "flash", duration = 1.0 })
	anima.also({ node = $MeshInstance, animation = "bounce" })

	anima.play()
