extends Control

func _ready():
	Anima.begin_single_shot(self) \
		.with(
			Anima.Node($Label).anima_animation_frames({
				0: {
					"translate:x": "-:size:x",
				},
				100: {
					"translate:x": 0,
				}
			})
		) \
		.play()
