extends PanelContainer

func _ready():
	$Container/PanelContainer/PanelContainer/BaseButton.hide()
	$Container/SpriteContainer/Anima.global_transform.origin = Vector2(100, 100)

	for easing_name in ANIMA.EASING.keys():
		var easing_value = ANIMA.EASING[easing_name]

		var text = easing_name
		text = text.replace('EASE_IN_', '')
		text = text.replace('EASE_OUT_', '')
		text = text.replace('EASE_IN_OUT_', '')

		_add_button(text, easing_name, easing_value)

	_add_button("Spring", "SPRING_OUT", "spring")

func _add_button(text: String, easing_name: String, easing_value):
	var button := $Container/PanelContainer/PanelContainer/BaseButton.duplicate()

	button.text = text.replace('_', ' ').capitalize()
	button.show()
	button.connect("pressed",Callable(self,'_on_easing_button_pressed').bind(easing_value))

	if easing_name.find('_IN_OUT_') > 0:
		$Container/PanelContainer/PanelContainer/HBoxContainer/InOut/GridInOut.add_child(button)
	elif easing_name.find('_OUT') > 0:
		$Container/PanelContainer/PanelContainer/HBoxContainer/Out/GridOut.add_child(button)
	else:
		$Container/PanelContainer/PanelContainer/HBoxContainer/In/GridIn.add_child(button)
	
func _on_easing_button_pressed(easing_value) -> void:
	var size = self.size
	var logo_size = AnimaNodesProperties.get_size($Container/SpriteContainer/Anima)

	var anima = Anima.begin(self, 'easings') \
		.then(
			Anima.Node($Container/SpriteContainer/Anima)
				.anima_position(Vector2(size.x - logo_size.x - 100, 100), 1)
				.anima_from(Vector2(100, 100))
				.anima_easing(easing_value)
			) \
		.play()
