extends PanelContainer

func _ready():
	$Container/PanelContainer/PanelContainer/BaseButton.hide()
	$Container/SpriteContainer/Anima.global_transform.origin = Vector2(100, 100)

	for easing_name in Anima.EASING.keys():
		var easing_value = Anima.EASING[easing_name]
		var button := $Container/PanelContainer/PanelContainer/BaseButton.duplicate()

		var text = easing_name
		text = text.replace('EASE_IN_', '')
		text = text.replace('EASE_OUT_', '')
		text = text.replace('EASE_IN_OUT_', '')

		button.text = text.replace('_', ' ').capitalize()
		button.show()
		button.connect("pressed", self, '_on_easing_button_pressed', [easing_value])

		if easing_name.find('_IN_OUT_') > 0:
			$Container/PanelContainer/PanelContainer/HBoxContainer/InOut/GridInOut.add_child(button)
		elif easing_name.find('_OUT') > 0:
			$Container/PanelContainer/PanelContainer/HBoxContainer/Out/GridOut.add_child(button)
		else:
			$Container/PanelContainer/PanelContainer/HBoxContainer/In/GridIn.add_child(button)

func _on_easing_button_pressed(easing_value: int) -> void:
	var size = self.rect_size
	var logo_size = AnimaNodesProperties.get_size($Container/SpriteContainer/Anima)

	var anima = Anima.begin(self, 'easings')
	anima.then({node = $Container/SpriteContainer/Anima, property = "position", from = Vector2(100, 100), to = Vector2(size.x - logo_size.x - 100, 100), easing = easing_value, duration = 1})
	anima.play()
