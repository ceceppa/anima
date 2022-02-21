# Introduction

Creating rich animations can be a bit tedious, and Anima solves this problem for you. Allowing to run sequential, parallel and concurrent animations with few lines of code and simple syntax.
It has built-in about 89 animations and 33 easings, with the ability to easily add your own.

## Installation

Anima is a regular editor plugin. [Download the addon](https://github.com/ceceppa/anima) and copy the contents of addons/anima into the same folder in your project, and activate it in your project settings.

## Example

```gdscript
var anima := Anima.begin(self)

anima.then({ node = $node, animation = "tada", duration = 0.7 })
anima.play()
```

**NOTE** in Godot 4.0 you'll be able to wrap everything in parenthesis to avoid repeating "[variable].":

```gdscript
# Works on Godot 4.0 only:

var anima = (
  Anima.begin(self)
  .then({ node = $node, animation = "tada", duration = 0.7 })
)
```

## Live demo

Do you want to give it a try? Here a live demo with some example: [https://anima.ceceppa.me/demo](https://anima.ceceppa.me/demo)

## Anima vs Tween

The aim of Anima is allowing you to write less and more maintainable code for your animations.
Let's have a look at this simple animation:

![Popup](../images/popup.gif)

Nothing too fancy, we have three nodes animated in sequence-ish... Let's have a look at how to implement it with both Anima and Godot Tween

**NOTE**: To have a fair comparison, I did not use any built-in animation.

### Anima code

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
	if data.animation == 'typewrite':
		var length = data.node.text.length()
		var real_duration = data.duration * length

		anima_tween.add_frames(data, 'visible_characters', [{ from = 0, to = length, duration = real_duration }])

		return real_duration

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

	var rotate_frames = [
		{ percentage = 0, to = 0 },
		{ percentage = 6.5, to = -9 },
		{ percentage = 18.5, to = +7 },
		{ percentage = 31.5, to = -5 },
		{ percentage = 43.5, to = +3 },
		{ percentage = 50, to = 0 },
		{ percentage = 100, to = 0 },
	]

	anima_tween.add_relative_frames(data, "x", shake_frames)
	anima_tween.add_frames(data, "rotation", rotate_frames)
```

### Godot Tween code

```gdscript
extends CenterContainer

func _ready():
	$Panel.hide()
	$Panel.rect_scale.y = 0
	$Panel/MarginContainer/Label.hide()
	$Panel/CenterContainer/Button.hide()

	var initial_delay := 0.5
	var scale_duration := 0.3

	var text_delay = initial_delay + scale_duration
	var text_length = $Panel/MarginContainer/Label.text.length()
	var text_duration := text_length * 0.05

	var button_duration := 0.5
	var button_initial_delay := -0.5

	var button_shake_frame1_duration = button_duration * 0.065 # 6.5%
	var button_shake_frame2_duration = button_duration * 0.185 # 18.5%
	var button_shake_frame3_duration = button_duration * 0.315 # 31.5%
	var button_shake_frame4_duration = button_duration * 0.435 # 43.5%
	var button_shake_frame5_duration = button_duration * 0.50 # 50.0%

	var button_shake_frame1_delay = initial_delay + text_duration + button_initial_delay
	var button_shake_frame2_delay = button_shake_frame1_delay + button_shake_frame1_duration
	var button_shake_frame3_delay = button_shake_frame2_delay + button_shake_frame2_duration
	var button_shake_frame4_delay = button_shake_frame3_delay + button_shake_frame3_duration
	var button_shake_frame5_delay = button_shake_frame4_delay + button_shake_frame4_duration

	var button_rotate_frame1_duration = button_duration * 0.065 # 6.5%
	var button_rotate_frame2_duration = button_duration * 0.185 # 18.5%
	var button_rotate_frame3_duration = button_duration * 0.315 # 31.5%
	var button_rotate_frame4_duration = button_duration * 0.435 # 43.5%
	var button_rotate_frame5_duration = button_duration * 0.50 # 50.0%

	var button_rotate_frame1_delay = initial_delay + text_duration + button_initial_delay
	var button_rotate_frame2_delay = button_rotate_frame1_delay + button_rotate_frame1_duration
	var button_rotate_frame3_delay = button_rotate_frame2_delay + button_rotate_frame2_duration
	var button_rotate_frame4_delay = button_rotate_frame3_delay + button_rotate_frame3_duration
	var button_rotate_frame5_delay = button_rotate_frame4_delay + button_rotate_frame4_duration

	var tween := Tween.new()
	add_child(tween)

	$Panel.set_pivot_offset($Panel.rect_size / 2)

	tween.interpolate_property($Panel, 'rect_scale:y', 0, 1, scale_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, initial_delay)
	tween.interpolate_property($Panel/MarginContainer/Label, 'visible_characters', 0, text_length, text_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, text_delay)

	var button_position = $Panel/CenterContainer/Button.rect_position
	# Shake
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 6, button_shake_frame1_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_shake_frame1_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 5, button_shake_frame2_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_shake_frame2_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 3, button_shake_frame3_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_shake_frame3_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 2, button_shake_frame4_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_shake_frame4_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x, button_shake_frame5_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_shake_frame5_delay )

  # Rotation
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', 0, -9, button_shake_frame1_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame1_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -9, 7, button_rotate_frame2_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame2_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -9, -5, button_rotate_frame3_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame3_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -5, 3, button_rotate_frame4_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame4_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', 3, 0, button_rotate_frame5_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame5_delay )

	tween.connect("tween_started", self, '_show_node')
	tween.start()

func _show_node(object, key) -> void:
	object.show()
```

### Difference

In terms of line of code we have

|Anima|Tween|
|---|---|
|56|70|

But the most significant difference is how the various animations are created and delayed.

#### Anima:

```gdscript
	anima.then({ node = $Panel, animation = 'scale_y', duration = 0.3 })
	anima.then({ node = $Panel/MarginContainer/Label, animation = 'typewrite', duration = 0.05 })
	anima.then({ node = $Panel/CenterContainer/Button, animation = 'button_animation', duration = 0.5, delay = -0.5 })
```

With Anima sequential animations are affected by the previous ones. So, the `typewrite` animation is delayed by the duration of the `scale_y` and the `button_animation` by the `scale_y` + `typewrite` one.

This means that changing the duration of one of them will automatically impact the delay of the subsequent sequential animations.

#### Godot

```gdscript
	tween.interpolate_property($Panel, 'rect_scale:y', 0, 1, scale_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, initial_delay)
	tween.interpolate_property($Panel/MarginContainer/Label, 'visible_characters', 0, text_length, text_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, text_delay)

	var button_position = $Panel/CenterContainer/Button.rect_position

	# Shake
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 6, button_frame1_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame1_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 5, button_frame2_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame2_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x - 3, button_frame3_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame3_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x + 2, button_frame4_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame4_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rect_position:x', button_position.x, button_position.x, button_frame5_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_frame5_delay )

  # Rotation
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', 0, -9, button_shake_frame1_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame1_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -9, 7, button_rotate_frame2_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame2_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -9, -5, button_rotate_frame3_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame3_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', -5, 3, button_rotate_frame4_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame4_delay)
	tween.interpolate_property($Panel/CenterContainer/Button, 'rotation_degrees', 3, 0, button_rotate_frame5_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, button_rotate_frame5_delay )
```

Here the situation got more complicated as, at the moment, there is no built-in support for chaining, and so it needs to be done manually by playing with delays.

Chaining the animation for Panel and Label is relatively easy. But the button shaking animation is more tricky as its composed of different frames and type of animations that are depend on the previous ones.
To make it more maintainable, you can do something like that:

```gdscript
	var initial_delay := 0.5
	var scale_duration := 0.3

	var text_delay = initial_delay + scale_duration
	var text_length = $Panel/MarginContainer/Label.text.length()
	var text_duration := text_length * 0.05

	var button_duration := 0.5
	var button_initial_delay := -0.5

	var button_shake_frame1_duration = button_duration * 0.065 # 6.5%
	var button_shake_frame2_duration = button_duration * 0.185 # 18.5%
	var button_shake_frame3_duration = button_duration * 0.315 # 31.5%
	var button_shake_frame4_duration = button_duration * 0.435 # 43.5%
	var button_shake_frame5_duration = button_duration * 0.50 # 50.0%

	var button_shake_frame1_delay = initial_delay + text_duration + button_initial_delay
	var button_shake_frame2_delay = button_shake_frame1_delay + button_shake_frame1_duration
	var button_shake_frame3_delay = button_shake_frame2_delay + button_shake_frame2_duration
	var button_shake_frame4_delay = button_shake_frame3_delay + button_shake_frame3_duration
	var button_shake_frame5_delay = button_shake_frame4_delay + button_shake_frame4_duration

	var button_rotate_frame1_duration = button_duration * 0.065 # 6.5%
	var button_rotate_frame2_duration = button_duration * 0.185 # 18.5%
	var button_rotate_frame3_duration = button_duration * 0.315 # 31.5%
	var button_rotate_frame4_duration = button_duration * 0.435 # 43.5%
	var button_rotate_frame5_duration = button_duration * 0.50 # 50.0%

	var button_rotate_frame1_delay = initial_delay + text_duration + button_initial_delay
	var button_rotate_frame2_delay = button_rotate_frame1_delay + button_rotate_frame1_duration
	var button_rotate_frame3_delay = button_rotate_frame2_delay + button_rotate_frame2_duration
	var button_rotate_frame4_delay = button_rotate_frame3_delay + button_rotate_frame3_duration
	var button_rotate_frame5_delay = button_rotate_frame4_delay + button_rotate_frame4_duration
```

this makes easier to change the duration and delay of each part of the total animation, but still we have extra 33 lines to maintain.

#### Easing

What if you want to emulate one of the easing available with Anima? 

Then the situation will get more complicated as you need to use something like:

```gdscript
tween.interpolate_method(self, '_my_easing', 0.0, 1.0, 0.3)

func _my_easing(elapsed_time: float) -> void:
	# here you need to calculate your easing value according to the elapsed time (0, 1)
	# also you need to know the node, property initial and final value to animate
	pass