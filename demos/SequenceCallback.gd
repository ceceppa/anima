extends HBoxContainer

var _animation: AnimaNode
var _check_sprites := []

func _ready():
	_animation = Anima.begin(self, 'sequence_callback')
	_animation.then({ node = $VBoxContainer/Button1, animation = "flash", duration = 1, on_completed = [funcref(self, '_on_button_completed'), [1]] })
	_animation.then({ node = $VBoxContainer/Button2, animation = "tada", duration = 1, on_completed = [funcref(self, '_on_button_completed'), [2]] })
	_animation.then({ node = $VBoxContainer/Button3, animation = "shakeX", duration = 1, on_completed = [funcref(self, '_on_button_completed'), [3]] })
	_animation.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	for i in range(1, 4):
		var sprite = find_node('check' + str(i))
		var anima = Anima.begin(sprite)

		anima.then({ node = sprite, animation = 'jello', duration = 0.5, hide_strategy = Anima.VISIBILITY.TRANSPARENT_ONLY })
		_check_sprites.push_back(anima)

func _on_Start_pressed():
	$MarginContainer/VBoxContainer/HBoxContainer/Label1.modulate = Color.white
	$MarginContainer/VBoxContainer/HBoxContainer2/Label2.modulate = Color.white
	$MarginContainer/VBoxContainer/HBoxContainer3/Label3.modulate = Color.white

#	for i in range(0, 3):
#		var ap: AnimationPlayer = _check_sprites[i]
#
#		ap.seek(0, true)

	_animation.play()

func _on_button_completed(index: int) -> void:
	var label: Label = find_node('Label' + str(index))

	var anima = Anima.begin(label)
	anima.then({ node = label, property = 'modulate', from = Color.white, to = Color.aqua, duration = 0.5 })

	anima.play()
	_check_sprites[index - 1].play()


