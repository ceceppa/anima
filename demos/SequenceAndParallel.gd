extends CenterContainer

func _init():
	Anima.register_animation(self, 'scale_y')

func _ready():
	var anima = Anima.begin(self, 'sequence_and_parallel')
	anima.then({ node = $Panel, animation = 'scale_y', duration = 0.3 })
	anima.then({ node = $Panel/MarginContainer/Label, animation = 'typewrite', duration = 0.05 })
	anima.then({ node = $Panel/CenterContainer/Button, animation = 'tada', duration = 0.5, delay = -0.5 })

	anima.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY)

	anima.play_with_delay(0.5)

func _on_Button_pressed():
	var anima = Anima.begin(self, 'fade_out')
	anima.with({ node = $Panel, animation = 'fadeOut', duration = 0.3 })
	anima.with({ node = $Panel/MarginContainer/Label, animation = 'fadeOut', duration = 0.3 })
	anima.with({ node = $Panel/CenterContainer/Button, animation = 'fadeOut', duration = 0.3 })
	anima.play()

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	anima_tween.add_frames(data, 'scale:y', [ { from = 0, to = 1, pivot = Anima.PIVOT.CENTER } ])
