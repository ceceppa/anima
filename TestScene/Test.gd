extends Control

const Test := {}

@export (StyleBoxFlat) var test :
	get:
		return test # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_test

var anima: AnimaNode 

func _ready():
#	$AnimaVisualNode.play_animation("default")

#	var anima: AnimaNode = Anima.begin_single_shot(self)

#	anima.then(
#		Anima.Node($RichTextLabel) \
#			super.anima_animation("typewrite") \
#			super.anima_duration(0.3)
#	)
#	anima.with({
#		property = "opacity",
#		from = 0.0,
#		to = 1.0,
#	})
#	anima.then(
#		Anima.Node($Button) \
#		super.anima_duration(0.3) \
#		super.anima_animation(
#			{
#				0: {
#					y = -20,
#					opacity = 0,
#				},
#				100: {
#					y = 0,
#					opacity = 1,
#					easing = ANIMA.EASING.EASE_IN_OUT_BACK
#				},
#				initial_values = {
#					opacity = 0,
#				}
#			}
#		)
#	)
	
#	anima.with(
#		Anima.Group($Control) \
#			super.anima_animation("zoomIn") \
#			super.anima_sequence_type(ANIMA.GRID.SEQUENCE_BOTTOM_RIGHT) \
#			super.anima_items_delay(1)
#	)
#
#	anima.then(
#		Anima.Node($AnimaRectangle) \
#			super.anima_property("Rectangle/FillColor") \
#			super.anima_from(Color.TRANSPARENT) \
#			super.anima_to(Color.YELLOW) \
#			super.anima_duration(1)
#	)
#	$AnimaRectangle.set("Rectangle/FillColor", Color.YELLOW)
#	anima.play_with_delay(0.5)
#
#	await anima.animation_completed
#
#	await get_tree().create_timer(1).timeout
#
#	print_orphan_nodes()
#	print_tree_pretty()
#

#		super.then(Anima.Node($CanvasModulate).anima_property("color", Color.REBECCA_PURPLE, 0.5)) \
#	anima = Anima.begin(self) \
#		super.then(Anima.Node($CanvasModulate).anima_animation_frames({
#			to = {
#				color = Color.REBECCA_PURPLE
#			},
#			initial_values = {
#				color = Color.YELLOW
#			}
#		}, 0.5)
#	).play_with_delay(2)
	Anima.begin(self) \
		super.with(
			Anima.Node($Button).anima_animation("headshake", 1)
		).play()

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

func _on_v_changed() -> void:
	pass

func set_test(v: StyleBoxFlat) -> void:
	test = v
	v.connect("changed",Callable(self,"_on_v_changed"))

func _on_Button_pressed():
	var button_size := 178
	var half_screen_x := 1024 / 2 - button_size / 2

	Anima.begin(self).then(
		Anima.Node($Button).anima_position_x(half_screen_x, 1).anima_from(-178)
	).play_with_delay(1)

