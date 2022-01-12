extends Control

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self)
	anima.then(
		Anima.Node($RichTextLabel) \
			.anima_property("x") \
			.anima_from(100) \
			.anima_to(200) \
			.anima_duration(1) \
			.anima_initial_value(500)
	)

	anima.play_with_delay(0.5)
