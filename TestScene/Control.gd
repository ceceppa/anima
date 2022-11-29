extends Control

func _ready():
	Anima.begin_single_shot(self) \
		.with( Anima.Node($Label).anima_animation("bounce", 1 ) ) \
		.play_with_delay(0.5)

#		.with(
#			Anima.Node($Label).anima_animation_frames({
#				0: {
#					"translate:x": 0,
#				},
#				50: {
#					"translate:x": -100,
#				},
#				100: {
#					"translate:x": 100,
#				}
#			})
#		) \
