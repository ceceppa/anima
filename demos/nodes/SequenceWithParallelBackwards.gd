extends Node2D

func _ready():
	var cross := $cross

	var anima = Anima.begin(self, 'position')
	anima.then({ node = cross, property = "X", to = 100, duration = 1, relative = true, easing = ANIMA.EASING.EASE_IN_SINE })
	anima.with({ node = cross, property = "rotation", from = 0, to = 360, easing = ANIMA.EASING.EASE_IN_SINE })

	anima.then({ node = cross, property = "y", to = 100, duration = 1, relative = true })
	anima.with({ node = cross, property = "rotation", from = 0, to = -360 })

	anima.then({ node = cross, property = "X", to = -100, duration = 1, relative = true })
	anima.with({ node = cross, property = "rotation", from = 0, to = 360 })

	anima.then({ node = cross, property = "Y", to = -100, duration = 1, relative = true, easing = ANIMA.EASING.EASE_OUT_CIRC })
	anima.with({ node = cross, property = "rotation", from = 0, to = -360, easing = ANIMA.EASING.EASE_OUT_CIRC })

	anima.play_backwards_with_delay(0.2)
