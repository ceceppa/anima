tool
extends Control

onready var ANIMATION_DATA = preload("res://addons/anima/ui/editor/AnimaAnimationData.tscn")
onready var INITIAL_DATA = preload("res://addons/anima/ui/editor/InitialValue.tscn")

signal frame_deleted
signal select_node
signal frame_updated
signal select_animation
signal select_easing
signal select_relative_property
signal highlight_node(node)

export (bool) var animate_entrance_exit := true
export (bool) var is_initial_frame := false setget set_is_initial_frame

onready var _animations_container = find_node("AnimationsContainer")
onready var _frame_name = find_node("FrameName")
onready var _duration = find_node("Duration")

var _source: Node
var _final_width: float = 460

func _ready():
	if animate_entrance_exit:
		_animate_me()
	else:
		rect_min_size.x = _final_width

	set_is_initial_frame(is_initial_frame)

func get_data() -> Dictionary:
	var data := {
		name = _frame_name.get_label(),
		duration = _duration.get_value(),
		type = "frame",
		data = []
	}

	for child in _animations_container.get_children():
		if is_instance_valid(child):
			data.data.push_back(child.get_data())

	return data

func set_name(name: String) -> void:
	_frame_name.set_label(name)
	_frame_name.set_initial_value("Frame01")
	_frame_name.set_placeholder("Frame01")

func set_duration(duration: float) -> void:
	_duration.set_value(duration)

func clear() -> void:
	for child in _animations_container.get_children():
		child.queue_free()

func add_animation_for(node: Node, path: String, property, property_value) -> Node:
	var animation_item: Node = INITIAL_DATA.instance() if is_initial_frame else ANIMATION_DATA.instance() 

	_animations_container.add_child(animation_item)

	animation_item.connect("updated", self, "_on_animation_data_updated")
	animation_item.connect("removed", self, "_on_animation_data_removed")

	if not is_initial_frame:
		animation_item.connect("highlight_node", self, "_on_highlight_node")

	if animation_item.has_signal("select_animation"):
		animation_item.connect("select_animation", self, "_on_select_animation", [animation_item])
		animation_item.connect("select_easing", self, "_on_select_easing", [animation_item])
		animation_item.connect("select_relative_property", self, "_on_select_relative_property", [animation_item])

	animation_item.set_data(node, path, property, property_value)

	return animation_item

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
				easing = ANIMA.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node(find_node("ContentContainer")).anima_fade_in().anima_initial_value(0)
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
					easing = ANIMA.EASING.EASE_OUT_BACK
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
				easing = ANIMA.EASING.EASE_OUT_BACK
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

func set_is_initial_frame(new_is_initial_frame: bool):
	is_initial_frame = new_is_initial_frame

	find_node("DurationContainer").visible = !is_initial_frame
	find_node("RemoveWrapper").visible = !is_initial_frame
	find_node("PlayButton").visible = !is_initial_frame
	find_node("FrameName").set_can_edit_value(!is_initial_frame)

func _on_Delete_pressed():
	if animate_entrance_exit:
		yield(_animate_me(true), "completed")

	queue_free()
	emit_signal("frame_deleted")

func _on_AddAnimation_pressed():
	emit_signal("select_node")

func _on_animation_data_updated() -> void:
	emit_signal("frame_updated")

func _on_FrameName_confirmed():
	emit_signal("frame_updated")

func _on_animation_data_removed(source: Node) -> void:
	source.queue_free()

	emit_signal("frame_updated")

func _on_select_animation(source: Node) -> void:
	_source = source

	emit_signal("select_animation")

func _on_highlight_node(source: Node) -> void:
	emit_signal("highlight_node", source)
