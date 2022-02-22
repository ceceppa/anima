tool
extends AnimaRectangle

var _is_collapsed_mode := true

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	var dotted = $AddButton/Dotted

	dotted.rect_position = (self.rect_position - dotted.rect_position) / 2

	anima.then(
		Anima.Node($AddButton).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Node($AddButton/Dotted/Plus/Vertical) \
			.anima_animation_frames({
				from = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(5, 40)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node($AddButton/Dotted/Plus/Horizontal) \
			.anima_animation_frames({
				from = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(40, 5)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)

	anima.play_with_delay(1.0)

func _animate_add_button() -> void:
	var anima: AnimaNode = Anima.begin(self)

	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node($AddButton) \
			.anima_relative_position_y(200) \
			.anima_easing(Anima.EASING.EASE_IN_OUT_BACK)
	)

	anima.with(
		Anima.Node($AddButton/Dotted) \
			.anima_animation_frames({
				from = {
					PROPERTIES.RECTANGLE_FILL_COLOR.name: Color.transparent,
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(100, 100)),
					PROPERTIES.RECTANGLE_RADIUS_BOTTOM_LEFT.name: 8,
					PROPERTIES.RECTANGLE_RADIUS_BOTTOM_RIGHT.name: 8,
					PROPERTIES.RECTANGLE_RADIUS_TOP_LEFT.name: 8,
					PROPERTIES.RECTANGLE_RADIUS_TOP_RIGHT.name: 8,
					PROPERTIES.RECTANGLE_BORDER_COLOR.name: Color("66667a"),
				},
				to = {
					PROPERTIES.RECTANGLE_FILL_COLOR.name: Color.white,
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(80, 80)),
					PROPERTIES.RECTANGLE_RADIUS_BOTTOM_LEFT.name: 51,
					PROPERTIES.RECTANGLE_RADIUS_BOTTOM_RIGHT.name: 51,
					PROPERTIES.RECTANGLE_RADIUS_TOP_LEFT.name: 51,
					PROPERTIES.RECTANGLE_RADIUS_TOP_RIGHT.name: 51,
					PROPERTIES.RECTANGLE_BORDER_COLOR.name: Color("88888a"),
				},
			})
	)
	
	anima.with(
		Anima.Group($AddButton/Dotted, 0.0).anima_fade_out(0.01)
	)
	
	anima.with(
		Anima.Node($AddButton/Dotted/Plus) \
			.anima_animation_frames({
				from = {
					rotate = 0,
					modulate = Color.white,
				},
				to = {
					rotate = 45,
					modulate = Color.black,
				}
			})
	)
	anima.with(
		Anima.Node($AddButton).anima_scale(Vector2.ONE)
	)

	anima.play()

func _on_AddButton_mouse_entered():
	$AddButton.set_scale(Vector2(1.2, 1.2))

	var color: Color = Color.white if _is_collapsed_mode else Color.black

	$AddButton/Dotted/Plus.animate_param("modulate", color)
	$AddButton/Dotted.animate_param(PROPERTIES.RECTANGLE_BORDER_COLOR.name, Color.white)

func _on_AddButton_mouse_exited():
	$AddButton.set_scale(Vector2.ONE)
	
	var color: Color = Color("f8314569") if _is_collapsed_mode else Color("#ee786c")
	$AddButton/Dotted/Plus.animate_param("modulate", Color(color))
	$AddButton/Dotted.animate_param(PROPERTIES.RECTANGLE_BORDER_COLOR.name, Color("66667a"))

func _on_AddButton_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		_is_collapsed_mode = not _is_collapsed_mode

		_animate_add_button()
