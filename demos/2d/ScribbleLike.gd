extends Node

var text = "Hello Godot!"
var _is_test := false

func _ready():
	var container = find_child("HBoxContainer")

	for letter_index in text.length():
		var letter:String = text[letter_index]
		var letter_container := Control.new()
		var single_letter := Label.new()

		single_letter.text = letter
#		single_letter.add_theme_font_size_override("font_size", 92)

		letter_container.add_child(single_letter)

		container.add_child(letter_container)

		letter_container.custom_minimum_size = single_letter.size

	Anima.Group(container, 0.01) \
		.anima_animation_frames({
			0: {
				"translate:y": -40,
				"opacity": 0,
			},
			100: {
				"translate:y": 0,
				"opacity": 1,
				"easing": "spring(1, 80, 8)"
			},
			"initial_values": {
				opacity = 0,
			},
		}, 1) \
		.play_with_speed(0.5)
