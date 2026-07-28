extends HBoxContainer

var _animation: AnimaNode
var _check_sprites := []

func _test_me():
	print("started")

func _ready():
	_animation = AnimaV1.begin(self, 'sequence_callback') \
		.then( 
			AnimaV1.Node($VBoxContainer/Button1)
				.anima_animation("flash", 1)
				.anima_on_started(_test_me)
				.anima_on_completed(_on_button_completed, [1])
		) \
		.then(
			AnimaV1.Node($VBoxContainer/Button2)
				.anima_animation("flash", 1)
				.anima_on_started(_test_me)
				.anima_on_completed(_on_button_completed, [2])
		) \
		.then( 
			AnimaV1.Node($VBoxContainer/Button3)
				.anima_animation("flash", 1)
				.anima_on_started(_test_me)
				.anima_on_completed(_on_button_completed, [3])
		) \
		.set_visibility_strategy(ANIMA.VISIBILITY.TRANSPARENT_ONLY)

	for i in range(1, 4):
		var sprite = find_child('check' + str(i))
		var anima = AnimaV1.begin(sprite)

		anima.then(
			AnimaV1.Node(sprite) \
			.anima_animation("jello", 0.5) \
			.anima_visibility_strategy(ANIMA.VISIBILITY.TRANSPARENT_ONLY)
		)

		_check_sprites.push_back(anima)

func _on_Start_pressed():
	$MarginContainer/VBoxContainer/HBoxContainer/Label1.modulate = Color.WHITE
	$MarginContainer/VBoxContainer/HBoxContainer2/Label2.modulate = Color.WHITE
	$MarginContainer/VBoxContainer/HBoxContainer3/Label3.modulate = Color.WHITE

#	for i in range(0, 3):
#		var ap: AnimationPlayer = _check_sprites[i]
#
#		ap.seek(0, true)

	_animation.play()

func _on_button_completed(index: int) -> void:
	print("completed")
	var label: Label = find_child('Label' + str(index))

	var anima = AnimaV1.begin(label)
	anima.then(
		AnimaV1.Node(label) \
		.anima_property("modulate", Color.AQUA, 0.5) \
		.anima_from(Color.WHITE)
	)

	anima.play()
	_check_sprites[index - 1].play()
