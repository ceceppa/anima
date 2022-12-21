tool
extends MarginContainer

var _is_collapsed_mode := true

signal add_frame
signal add_event
signal add_delay

onready var _buttons_container = find_node("ButtonsContainer")
onready var _add_button = find_node("AddButton")

func _ready():
	for child in _buttons_container.get_children():
		child.modulate.a = 0

func _animate_add(mode:int) -> void:
	var anima := Anima.begin_single_shot(self) \
	.then(
		Anima.Node(_add_button).anima_scale(Vector2(1.2, 1.2), 0.15)
	) \
	.with(
		Anima.Group(_buttons_container, 0.05) \
			.anima_animation_frames({
				from = {
					x = 0,
					y = 0,
					scale = Vector2.ZERO,
					opacity = 0,
				},
				70: {
					opacity = 1,
				},
				to = {
					x = "sin(:index * PI - PI / 2) * (:size:x / 1.5)",
					y = "cos(:index * PI - PI / 2) * (:size:y / 2)",
					scale = Vector2.ONE,
				},
				pivot = ANIMA.PIVOT.CENTER,
				easing = ANIMA.EASING.EASE_OUT_BACK
			}, 0.3)
	) \
	.play_as_backwards_when(mode == AnimaTween.PLAY_MODE.BACKWARDS)

	yield(anima, "animation_completed")

	var mouse_filter = MOUSE_FILTER_STOP if _buttons_container.get_child(0).modulate.a > 0 else MOUSE_FILTER_IGNORE
	
	for button in _buttons_container.get_children():
		button.mouse_filter = mouse_filter

func _on_Animation_pressed():
	_on_Timer_timeout()
	
	emit_signal("add_frame")

func _on_Delay_pressed():
	_on_Timer_timeout()

	emit_signal("add_delay")

func _on_Event_pressed():
	emit_signal("add_event")

func _on_AddButton_mouse_entered():
	$Timer.stop()

	if _buttons_container.get_child(0).modulate.a < 1:
		_animate_add(AnimaTween.PLAY_MODE.NORMAL)

func _on_Timer_timeout():
	_animate_add(AnimaTween.PLAY_MODE.BACKWARDS)

func _on_mouse_entered():
	$Timer.stop()

func _on_mouse_exited():
	$Timer.start()

func update_position(parent_size: Vector2):
	rect_position = parent_size - $AddButton.rect_size - Vector2(200, 92)
