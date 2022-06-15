tool
extends Control

var _is_collapsed_mode := true

signal add_frame
signal add_event
signal add_delay

onready var _dotted = find_node("Dotted")
onready var _plus = find_node("Plus")
onready var _add_button: AnimaAnimatable = find_node("AddButton")
onready var _buttons_container: VBoxContainer = find_node("ButtonsContainer")

var _ratio: float = 1.0

func _ready():
	var final_width: float = 360

	rect_min_size.x = final_width * _ratio
	_buttons_container.rect_min_size.x = 240 * _ratio

	_animate_me()

func _animate_me():
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	_dotted.rect_position = (self.rect_position - _dotted.rect_position) / 2

	anima.then(
		Anima.Node(_add_button).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Node(_plus.get_child(1)) \
			.anima_animation_frames({
				from = {
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(5, 40)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node(_plus.get_child(0)) \
			.anima_animation_frames({
				from = {
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(40, 5)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)

	anima.play_with_delay(0.3)

	for child in _buttons_container.get_children():
		child.modulate.a = 0
		child.rect_min_size.y = 48 * _ratio

func _animate_add_button() -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node(_add_button) \
			.anima_relative_position_y(200) \
			.anima_easing(Anima.EASING.EASE_OUT_BACK)
	)

	anima.with(
		Anima.Node(_dotted) \
			.anima_animation_frames({
				from = {
					AnimaRectangle.PROPERTIES.RECTANGLE_FILL_COLOR.name: Color.transparent,
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(100, 100)),
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_BOTTOM_LEFT.name: 8,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_BOTTOM_RIGHT.name: 8,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_TOP_LEFT.name: 8,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_TOP_RIGHT.name: 8,
					AnimaRectangle.PROPERTIES.RECTANGLE_BORDER_COLOR.name: Color("66667a"),
					AnimaRectangle.PROPERTIES.RECTANGLE_SHADOW_SIZE.name: 0
				},
				to = {
					AnimaRectangle.PROPERTIES.RECTANGLE_FILL_COLOR.name: Color.white,
					AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(60, 60)),
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_BOTTOM_LEFT.name: 51,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_BOTTOM_RIGHT.name: 51,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_TOP_LEFT.name: 51,
					AnimaRectangle.PROPERTIES.RECTANGLE_RADIUS_TOP_RIGHT.name: 51,
					AnimaRectangle.PROPERTIES.RECTANGLE_BORDER_COLOR.name: Color("ee786c"),
					AnimaRectangle.PROPERTIES.RECTANGLE_SHADOW_SIZE.name: 10
				},
			})
	)

	anima.with(
		Anima.Group(_dotted, 0.0).anima_fade_out(0.01)
	)

	anima.with(
		Anima.Node(_plus) \
			.anima_animation_frames({
				from = {
					rotate = 0,
					modulate = Color("f8314569"),
				},
				to = {
					rotate = 45,
					modulate = Color("ee786c"),
					easing = Anima.EASING.EASE_IN_OUT
				},
			})
	)

	anima.with(
		Anima.Node(_plus.get_child(0)) \
			.anima_animation_frames({
				from = {
				AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(40, 5)),
				},
				to = {
				AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(20, 2)),
				},
			})
	)

	anima.with(
		Anima.Node(_plus.get_child(1)) \
			.anima_animation_frames({
				from = {
				AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(5, 40)),
				},
				to = {
				AnimaRectangle.PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(2, 20)),
				},
			})
	)

	anima.with(
		Anima.Node(_add_button).anima_scale(Vector2.ONE)
	)

	anima.with(
		Anima.Group(_buttons_container, 0.05) \
			.anima_animation_frames({
				from = {
					scale = Vector2(0.8, 0.8),
					opacity = 0,
				},
				to = {
					scale = Vector2.ONE,
					opacity = 1.0,
					easing = Anima.EASING.EASE_OUT_BACK
				}
			})
	)

	if _is_collapsed_mode:
		anima.play()
	else:
		anima.play_backwards_with_speed(1.4)

	_is_collapsed_mode = not _is_collapsed_mode

func _button_in(node: AnimaButton) -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self, node.name)

	anima.then(
		Anima.Node(node) \
			.anima_scale(Vector2(1.05, 1.05), 0.15) \
			.anima_easing(Anima.EASING.EASE_OUT_BACK)
	)

	anima.play()

func _button_out(node: AnimaButton) -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self, node.name)

	anima.then(
		Anima.Node(node) \
			.anima_scale(Vector2.ONE, 0.15) \
			.anima_easing(Anima.EASING.EASE_IN_OUT)
	)

	anima.play()

func _on_AddButton_mouse_entered():
	_add_button.set_scale(Vector2(1.2, 1.2))

	var color: Color = Color.white if _is_collapsed_mode else Color("ee786c")

	_plus.animate_param("modulate", color)
	
	if _is_collapsed_mode:
		_dotted.animate_param(AnimaRectangle.PROPERTIES.RECTANGLE_BORDER_COLOR.name, Color.white)

func _on_AddButton_mouse_exited():
	_add_button.set_scale(Vector2.ONE)
	
	var color: Color = Color("f8314569") if _is_collapsed_mode else Color("#ee786c")

	_plus.animate_param("modulate", Color(color))

	if _is_collapsed_mode:
		_dotted.animate_param(AnimaRectangle.PROPERTIES.RECTANGLE_BORDER_COLOR.name, Color("66667a"))

func _on_AddButton_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		_animate_add_button()

func _on_Animation_pressed():
	if _is_collapsed_mode:
		return

	_animate_add_button()

	emit_signal("add_frame")

func _on_Delay_pressed():
	if _is_collapsed_mode:
		return

	_animate_add_button()

	emit_signal("add_delay")

func _on_Event_pressed():
	if _is_collapsed_mode:
		return

	_animate_add_button()

	emit_signal("add_event")
