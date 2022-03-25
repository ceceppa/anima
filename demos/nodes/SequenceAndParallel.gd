extends CenterContainer

func _ready():
	Anima.begin_single_shot(self, 'sequence_and_parallel') \
		.then( Anima.Node($Panel).anima_scale_y(1, 0.3).anima_from(0).debug() ) \
		.then( Anima.Node($Panel/MarginContainer/Label).anima_animation('typewrite', 0.05) ) \
		.then( Anima.Node($Panel/CenterContainer/Button).anima_animation('tada', 0.5 ).anima_delay(-0.5) ) \
		.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY) \
		.play_with_delay(0.5)

func _on_Button_pressed():
	var anima = Anima.begin(self, 'fade_out')
	anima.with({ node = $Panel, animation = 'fadeOut', duration = 0.3 })
	anima.with({ node = $Panel/MarginContainer/Label, animation = 'fadeOut', duration = 0.3 })
	anima.with({ node = $Panel/CenterContainer/Button, animation = 'fadeOut', duration = 0.3 })
	anima.play()
