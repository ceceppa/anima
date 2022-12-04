extends HBoxContainer

var _animation: AnimaNode
var _check_sprites := []

func _ready():
	_animation = Anima.begin(self, 'sequence_callback') \
		.then( Anima.Node($VBoxContainer/Button1).anima_animation("flash", 1).anima_on_completed(self, '_on_button_completed', [1]) ) \
		.then( Anima.Node($VBoxContainer/Button2).anima_animation("flash", 1).anima_on_completed(self, '_on_button_completed', [2]) ) \
		.then( Anima.Node($VBoxContainer/Button3).anima_animation("flash", 1).anima_on_completed(self, '_on_button_completed', [3]) ) \
		.set_visibility_strategy(ANIMA.VISIBILITY.TRANSPARENT_ONLY)

	for i in range(1, 4):
		var sprite = find_node('check' + str(i))
		var anima = Anima.begin(sprite)

		anima.then(
			Anima.Node(sprite) \
			.anima_animation("jello", 0.5) \
			.anima_visibility_strategy(ANIMA.VISIBILITY.TRANSPARENT_ONLY)
		)

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
	anima.then(
		Anima.Node(label) \
		.anima_property("modulate", Color.aqua, 0.5) \
		.anima_from(Color.white)
	)

	anima.play()
	_check_sprites[index - 1].play()


