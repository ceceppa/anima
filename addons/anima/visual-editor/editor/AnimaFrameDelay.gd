@tool
extends Control

signal frame_deleted
signal frame_updated
signal move_one_left
signal move_one_right

const FINAL_WIDTH := 360.0

@export var animate_entrance_exit := true

@onready var _delay = find_child("DelayValue")

func _ready():
	if animate_entrance_exit:
		_animate_me()

func get_data() -> Dictionary:
	return {
		type = "delay",
		data = {
			delay = _delay.get_value()
		}
	}

func restore_data(data: Dictionary) -> void:
	if _delay == null:
		_delay = find_child("DelayValue")

	_delay.set_value(data.delay)

func _animate_me(backwards := false) -> AnimaNode:

	var anima: AnimaNode = Anima.begin_single_shot(self)
	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node(self) \
			.anima_animation_frames({
				from = {
					"size:x": 0,
					"min_size:x": 0,
				},
				to = {
					"size:x": FINAL_WIDTH,
					"min_size:x": FINAL_WIDTH,
				},
				easing = ANIMA.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node(find_child("CenterContainer")).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Group(find_child("DelayContent"), 0.05) \
			.anima_animation_frames({
				from = {
					y = 40,
					opacity = 0,
				},
				to = {
					y = 0,
					opacity = 1,
					easing = ANIMA.EASING.EASE_OUT_BACK
				},
				initial_values = {
					opacity = 0
				}
			})
	)

	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	return anima

func _on_Delete_pressed():
	if animate_entrance_exit:
		await _animate_me(true).animation_completed

	queue_free()
	emit_signal("frame_deleted")

func _on_DelayValue_changed():
	emit_signal("frame_updated")
func set_has_previous(has: bool) -> void:
	_maybe_set_visible("MoveLeft", has)

func set_has_next(has: bool) -> void:
	_maybe_set_visible("MoveRight", has)

func _maybe_set_visible(node_name: String, visible: bool) -> void:
	var node = find_child(node_name)

	if node:
		node.visible = visible

func _on_MoveRight_pressed():
	emit_signal("move_one_right")

func _on_MoveLeft_pressed():
	emit_signal("move_one_left")
