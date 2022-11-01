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
signal preview_frame

export (bool) var animate_entrance_exit := true
export (bool) var is_initial_frame := false setget set_is_initial_frame

onready var _animations_container = find_node("AnimationsContainer")
onready var _frame_name = find_node("FrameName")
onready var _duration = find_node("Duration")

var _source: Node
var _final_width: float = 640 if OS.get_screen_dpi() > 100 else 460
var _old_height: float

func _ready():
	$Rectangle.rect_size.x = _final_width

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
		data = [],
		collapsed = $Collapse.pressed()
	}

	for child in _animations_container.get_children():
		if is_instance_valid(child):
			data.data.push_back(child.get_data())

	return data

func set_name(name: String) -> void:
	if _frame_name == null:
		_frame_name = find_node("FrameName")

	if is_initial_frame:
		name = "Initial Frame"

	_frame_name.set_label(name)
	_frame_name.set_initial_value(name)
	_frame_name.set_placeholder(name)

func set_duration(duration: float) -> void:
	_duration.set_value(duration)

func clear() -> void:
	for child in _animations_container.get_children():
		child.queue_free()

func add_animation_for(node: Node, path: String, property, property_type) -> Node:
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

	animation_item.set_data(node, path, property, property_type)

	return animation_item

func collapse() -> void:
	$Collapse.get_child(1).pressed = true

func _animate_me(backwards := false) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)
	
	anima.set_default_duration(0.3)

	anima.then(
		Anima.Nodes([self, $Rectangle]) \
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
	) \
	.with(
		Anima.Node(find_node("ContentContainer")).anima_fade_in().anima_initial_value(0)
	) \
	.with(
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
	) \
	.with(
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
	) \
	.with(
		Anima.Node($Rectangle).anima_fade_in()
	)

	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	yield(anima, "animation_completed")

	return anima

func set_is_initial_frame(new_is_initial_frame: bool):
	is_initial_frame = new_is_initial_frame

	find_node("DurationContainer").visible = !is_initial_frame
	find_node("Delete").visible = !is_initial_frame
	find_node("PlayButton").visible = !is_initial_frame
	find_node("FrameName").set_can_edit_value(!is_initial_frame)

func set_relative_property(node_path: String, property: String) -> void:
	_source.set_relative_propert(node_path, property)

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

func selected_animation(label, name) -> void:
	_source.selected_animation(label, name)

func set_easing(name: String, value: int) -> void:
	_source.set_easing(name, value)

func _on_select_relative_property(source: Node) -> void:
	_source = source

	emit_signal("select_relative_property")

func _on_select_easing(source: Node) -> void:
	_source = source

	emit_signal("select_easing")

func _on_Collapse_pressed():
	var anima := Anima.begin_single_shot(self, "collapse")
	
	anima.set_default_duration(0.3)

	$FrameCollapsedTitle.text = _frame_name.get_label()

	if $Collapse.pressed():
		anima.then(
			Anima.Node($Collapse) \
				.anima_animation_frames({
					to = {
						x = 0,
						y = 0,
						"size:y": "..:size:y",
						easing = ANIMA.EASING.EASE_IN_EXPO
					},
					relative = []
				})
		) \
		.with(
			Anima.Node(self) \
				.anima_animation_frames({
					to = {
						"min_size:x": $Collapse.rect_size.x,
						"size:x": $Collapse.rect_size.x,
					},
					easing = ANIMA.EASING.EASE_IN_EXPO
				})
		) \
		.with(
			Anima.Node($Collapse/Icon).anima_rotate(180)
		) \
		.with(
			Anima.Node($Rectangle).anima_fade_out()
		) \
		.then(
			Anima.Node($FrameCollapsedTitle).anima_animation_frames({
				from = {
					opacity = 0,
					x = -100,
				},
				to = {
					opacity = 1,
					x = -20,
					easing = ANIMA.EASING.EASE_OUT_BACK
				},
				initial_values = {
					y = "(..:size:y - .:size:y) / 2",
					x = -100
				},
				relative = []
			})
		)
	else:
		$Rectangle.rect_size.x = _final_width

		anima.then(
			Anima.Node($Rectangle).anima_fade_in()
		) \
		.with(
			Anima.Node($Collapse).anima_animation_frames({
				to = {
					x = _final_width - 80,
					y = 540,
					"size:y": ".:size:x",
					easing = ANIMA.EASING.EASE_OUT_EXPO
				},
				relative = []
			})
		) \
		.with(
			Anima.Node($Collapse/Icon).anima_rotate(0)
		) \
		.with(
			Anima.Node($FrameCollapsedTitle).anima_animation_frames({
				to = {
					opacity = 0,
					x = -100,
					easing = ANIMA.EASING.EASE_IN_EXPO
				},
				relative = []
			})
		)
		_animate_me(false)

	anima.play()

	yield(anima, "animation_completed")

	$Rectangle.rect_min_size.x = _final_width
	$Rectangle.rect_size.x = _final_width

	emit_signal("frame_updated")

func _on_FrameAnimation_item_rect_changed():
	if _old_height == rect_size.y:
		pass

	_old_height = rect_size.y

	if $Collapse.pressed():
		$Collapse.rect_size.y = rect_size.y
	else:
		$Collapse.rect_position.y = rect_size.y - $Collapse.rect_size.y - 12

func _on_PlayButton_pressed():
	emit_signal("preview_frame")

func _on_Collapse_mouse_entered():
	$FrameCollapsedTitle.add_color_override("font_color", Color.black)

func _on_Collapse_mouse_exited():
	$FrameCollapsedTitle.add_color_override("font_color", Color.white)
