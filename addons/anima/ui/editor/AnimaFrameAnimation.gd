tool
extends Control

const INITIAL_VALUE = preload("res://addons/anima/ui/editor/AnimaInitialValue.tscn")
const ANIMATION_DATA = preload("res://addons/anima/ui/editor/AnimaInitialValue.tscn")

signal frame_deleted
signal select_node

export (bool) var is_initial_frame := false setget set_is_initial_frame

onready var _animations_container = find_node("AnimationsContainer")

var _final_width: float = 460

func _ready():
	var frame_name = find_node("FrameName")

	frame_name.set_initial_value("Frame01")
	frame_name.set_placeholder("Frame01")

	if Engine.editor_hint:
		var cta_container: HBoxContainer = find_node("CTAContainer")

		var height: float = frame_name.rect_size.y
		var ratio = height / 32.0

		_final_width *= ratio

		cta_container.rect_position.y = -32 * ratio
		for child in cta_container.get_children():
			var s: Vector2 = Vector2(48, 48) * ratio
			child.rect_min_size = s

	_animate_me()

func add_animation_for(node: Node, path: String, property, property_value) -> void:
	var animation_item: Node

	if is_initial_frame:
		animation_item = INITIAL_VALUE.instance()
		animation_item.add_for(node, path, property, property_value)
	else:
		animation_item = ANIMATION_DATA.instance()

	_animations_container.add_child(animation_item)

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
					"size:x": _final_width,
					"min_size:x": _final_width,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node($Rectangle).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Group(find_node("ContentContainer"), 0.05) \
			.anima_animation_frames({
				from = {
					y = 40,
					opacity = 0,
				},
				to = {
					y = 0,
					opacity = 1,
					easing = Anima.EASING.EASE_OUT_BACK
				},
				initial_values = {
					opacity = 0
				}
			})
	)
	anima.with(
		Anima.Group(find_node("CTAContainer"), 0.05).anima_animation_frames({
			from = {
				scale = Vector2(0.1, 0.1),
				opacity = 0,
			},
			to = {
				scale = Vector2.ONE,
				opacity = 1,
				easing = Anima.EASING.EASE_OUT_BACK
			},
			initial_values = {
				opacity = 0,
			}
		}).anima_delay(0.1)
	)

	rect_clip_content = true

	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	yield(anima, "animation_completed")

	rect_clip_content = false

	return anima

func set_is_initial_frame(is_initial: bool) -> void:
	is_initial_frame = is_initial

	var frame_name = find_node("FrameName")
	var remove = find_node("RemoveWrapper")

	frame_name.set_initial_value("Initial Values")
	frame_name.can_edit_value = not is_initial
	frame_name.can_clear_custom_value = not is_initial

	if is_initial:
		frame_name.label = "Initial Values"

	remove.visible = not is_initial
	find_node("PlayContainer").visible = not is_initial
	find_node("DurationContainer").visible = not is_initial

func _on_Delete_pressed():
	yield(_animate_me(true), "completed")

	queue_free()
	emit_signal("frame_deleted")

func _on_AddAnimation_pressed():
	emit_signal("select_node")

#	print("here")
#	var add_button: AnimaButton = find_node("AddAnimation")
#	var position := add_button.rect_global_position
#	var rectangle := AnimaRectangle.new()
#
#	rectangle.rect_position = position
#
#	add_child(rectangle)
#	add_button.modulate.a = 0
#
#	var anima: AnimaNode = Anima.begin_single_shot(self, "addAnimation")
#	anima.set_default_duration(0.3)
#
#	anima.then(
#		Anima.Node(rectangle) \
#			.anima_position(Vector2(10, 100))
#	)
#	anima.with(
#		Anima.Node(rectangle) \
#			.anima_size(Vector2(340, 400))
#	)
#
#	anima.play()
