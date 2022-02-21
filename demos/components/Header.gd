extends Panel

var _anima: AnimaNode
var _back_button_anima: AnimaNode

func _ready():
	_anima = Anima.begin(self)
	_back_button_anima = Anima.begin($HBoxContainer/Control/BackButton, '_back_button')

	_anima.then({ property = "y", from = -100, to = 0, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK })
	_anima.wait(0.1)
	_anima.then({ node = $HBoxContainer/Label, animation = 'typewrite', duration = 0.3 })
	_anima.then({ group = $HBoxContainer/Filters, property = "scale", from = Vector2(0, 0), to = Vector2(1, 1), pivot = Anima.PIVOT.CENTER, easing = Anima.EASING.EASE_IN_OUT_BACK, duration = 0.3 })
	_anima.with({ group = $HBoxContainer/Filters, property = "opacity", from = 0, to = 1, duration = 0.3 })

	_anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	_back_button_anima.then({ animation = "bouncing_in_left", duration = 0.3 })
	_back_button_anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

func _get_anima() -> AnimaNode:
	return _anima
