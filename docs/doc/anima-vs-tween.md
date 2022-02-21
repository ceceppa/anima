# Anima vs Tween


```gdscript
extends CenterContainer

func _init():
	Anima.register_animation(self, 'scale_y')
	Anima.register_animation(self, 'button_animation')

func _ready():
	var anima = Anima.begin(self, 'sequence_and_parallel')
	anima.then({ node = $Panel, animation = 'scale_y', duration = 0.3 })
	anima.then({ node = $Panel/MarginContainer/Label, animation = 'typewrite', duration = 0.05 })
	anima.then({ node = $Panel/CenterContainer/Button, animation = 'button_animation', duration = 0.5, delay = -0.5 })

	anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	anima.play_with_delay(0.5)

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	if data.animation == 'button_animation':
		button_animation(anima_tween, data)

		return

	anima_tween.add_frames(data, 'scale:y', [ { from = 0, to = 1, pivot = Anima.PIVOT.CENTER } ])

func button_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var start = AnimaNodesProperties.get_position(data.node)

	var shake_frames = [
		{ percentage = 0, from = 0 },
		{ percentage = 6.5, to = -6 },
		{ percentage = 18.5, to = +5 },
		{ percentage = 31.5, to = -3 },
		{ percentage = 43.5, to = +2 },
		{ percentage = 50, to = 0 },
		{ percentage = 100, to = 0 },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_relative_frames(data, "x", shake_frames)
```

```gdscript
extends CenterContainer

func _ready():
	$Panel.hide()
	$Panel/MarginContainer/Label.hide()
	$Panel/CenterContainer/Button.hide()

	var initial_delay := 0.5
	var scale_duration := 0.3

	var text_delay = initial_delay + scale_duration
	var text_length = $Panel/MarginContainer/Label.text.length()
	var text_duration := text_length * 0.05

	var button_duration := 0.5
	var button_initial_delay := -0.5

	var button_frame1_duration = button_duration * 0.065 # 6.5%
	var button_frame2_duration = button_duration * 0.185 # 18.5%
	var button_frame3_duration = button_duration * 0.315 # 31.5%
	var button_frame4_duration = button_duration * 0.435 # 43.5%
	var button_frame5_duration = button_duration * 0.50 # 50.0%

	var button_frame1_delay = initial_delay + text_duration + button_initial_delay
	var button_frame2_delay = button_frame1_delay + button_frame1_duration
	var button_frame3_delay = button_frame2_delay + button_frame2_duration
	var button_frame4_delay = button_frame3_delay + button_frame3_duration
	var button_frame5_delay = button_frame4_delay + button_frame4_duration

	var tween := Tween.new()
	add_child(tween)

	$Panel.set_pivot_offset($Panel.rect_size / 2)

	tween.interpolate_property($Panel, 'rect_scale:y', 0, 1, scale_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, initial_delay)
	tween.interpolate_property($Panel/MarginContainer/Label, 'visible_characters', 0, text_length, text_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, text_delay)

	var button_position = $Panel/CenterContainer/Button.rect_position
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 6, button_frame1_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame1_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 5, button_frame2_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame2_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 3, button_frame3_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame3_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 2, button_frame4_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame4_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x, button_frame5_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame5_delay )

	<!-- tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 6, button_duration * 0.065, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5 + text_duration - 0.5)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 5, button_duration * 0.185, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5 + text_duration - 0.5 + (button_duration * 0.065) )
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 3, button_duration * 0.315, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5 + text_duration - 0.5 + (button_duration * 0.065) + (button_duration * 0.185) )
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 2, button_duration * 0.435, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5 + text_duration - 0.5 + (button_duration * 0.065) + (button_duration * 0.185) + (button_duration * 0.315) )
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x, button_duration * 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5 + text_duration - 0.5 + (button_duration * 0.065) + (button_duration * 0.185)  + (button_duration * 0.315) + (button_duration * 0.435) )
 -->
	tween.connect("tween_started", self, '_show_node')
	tween.start()

func _show_node(object, key) -> void:
	object.show()
```