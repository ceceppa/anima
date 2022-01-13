extends Control

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self)
	anima.then(
		Anima.Node($RichTextLabel) \
			.anima_animation("typewrite") \
			.anima_duration(1)
	)
	anima.then(
		Anima.Node($Button) \
		.anima_duration(0.3) \
		.anima_animation("zoomIn")
	)
	
	anima.play_with_delay(0.5)

