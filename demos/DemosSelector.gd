extends VBoxContainer

func _ready():
	Anima.Node($Control).anima_fade_in(0.5).anima_easing(ANIMA.EASING.EASE_IN_OUT).play()
	Anima.Node($Control).anima_scale(Vector2.ONE, 2.5).anima_from(Vector2.ZERO).anima_easing(ANIMA.EASING.EASE_IN_OUT).play()
	Anima.Node($Control).set_data({
		property = "scale",
		from = Vector2.ZERO,
		to = Vector2.ONE,
		easing = ANIMA.EASING.EASE_IN_OUT,
		duration = 0.5
	}).play()
