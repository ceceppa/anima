extends Control

const Test := {}

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self)

#	anima.then(
#		Anima.Node($RichTextLabel) \
#			.anima_animation("typewrite") \
#			.anima_duration(0.3)
#	)
#	anima.also({
#		property = "opacity",
#		from = 0.0,
#		to = 1.0,
#	})
#	anima.then(
#		Anima.Node($Button) \
#		.anima_duration(0.3) \
#		.anima_animation(
#			{
#				0: {
#					y = -20,
#					opacity = 0,
#				},
#				100: {
#					y = 0,
#					opacity = 1,
#					easing = Anima.EASING.EASE_IN_OUT_BACK
#				},
#				initial_values = {
#					opacity = 0,
#				}
#			}
#		)
#	)
	
#	anima.also(
#		Anima.Group($Control) \
#			.anima_animation("zoomIn") \
#			.anima_sequence_type(Anima.GRID.SEQUENCE_BOTTOM_RIGHT) \
#			.anima_items_delay(1)
#	)
#
#	anima.then(
#		Anima.Node($AnimaRectangle) \
#			.anima_property("Rectangle/FillColor") \
#			.anima_from(Color.transparent) \
#			.anima_to(Color.yellow) \
#			.anima_duration(1)
#	)
#	$AnimaRectangle.set("Rectangle/FillColor", Color.yellow)
	anima.play_with_delay(0.5)
#
#	yield(anima, "animation_completed")
#
#	yield(get_tree().create_timer(1), "timeout")
#
#	print_stray_nodes()
#	print_tree_pretty()
#

#	$AnimaNode.then({
#		node = $Control/Button2,
#		property = "opacity",
#		from = 0,
#		to = 1,
#		duration = 0.6
#	})
#
#	$AnimaNode.play_with_delay(0.5)

func ciao():
	print("hello")

var _temp

func _on_Button2_pressed():
	_ready()
	
	return
	print(_temp)

	if _temp == null:
		_temp = Button.new()

		add_child(_temp)
	else:
		_temp.free()
		_temp = null

