@tool
extends Control

@onready var ANIMATION_DATA = preload("res://addons/anima/visual-editor/editor/AnimaAnimationData.tscn")
@onready var INITIAL_DATA = preload("res://addons/anima/visual-editor/editor/InitialValue.tscn")

signal frame_deleted
signal select_node
signal add_node(node_path)
signal frame_updated
signal select_animation
signal select_easing
signal select_relative_property
signal highlight_node(node)
signal preview_frame
signal select_node_property(source, node_path)
signal move_one_left
signal move_one_right
signal preview_animation(preview_info)

@export (bool) var animate_entrance_exit := true
@export (bool) var is_initial_frame := false :
	get:
		return is_initial_frame # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_is_initial_frame

const _DO_NOT_ANIMATE_KEY = '_do_not_animate'

@onready var _animations_container = find_child("AnimationsContainer")
@onready var _frame_name = find_child("FrameName")
@onready var _duration = find_child("Duration")
@onready var _collapse_button = find_child("Collapse")
@onready var _frame_collapsed_title = find_child("FrameCollapsedTitle")

var _source: Node
var _final_width: float = 640
var _old_height: float
var _is_animating := false

func _ready():
	$Rectangle.size.x = _final_width

	if animate_entrance_exit:
		_animate_me()
	else:
		minimum_size.x = _final_width

	set_is_initial_frame(is_initial_frame)
	_on_DefaultFrameDuration_toggled(false)

func get_data() -> Dictionary:
	var data := {
		name = _frame_name.get_text(),
		duration = _duration.get_value(),
		type = "frame",
		data = [],
		collapsed = _collapse_button.pressed
	}

	for child in _animations_container.get_children():
		if is_instance_valid(child) and child.has_method("get_data") and not child.is_queued_for_deletion():
			data.data.push_back(child.get_data())

	return data

func set_name(name: String) -> void:
	if _frame_name == null:
		_frame_name = find_child("FrameName")

	if is_initial_frame:
		name = "Initial Frame"

	_frame_name.set_text(name)

func set_has_previous(has: bool) -> void:
	_maybe_set_visible("MoveLeft", has)

func set_has_next(has: bool) -> void:
	_maybe_set_visible("MoveRight", has)

func _maybe_set_visible(node_name: String, visible: bool) -> void:
	var node = find_child(node_name)

	if node:
		node.visible = visible

func set_duration(duration: float) -> void:
	_duration.set_value(duration)

func clear() -> void:
	for child in _animations_container.get_children():
		child.queue_free()

func add_animation_for(node: Node, path: String) -> Node:
	var animation_item: Node = INITIAL_DATA.instantiate() if is_initial_frame else ANIMATION_DATA.instantiate() 

	_animations_container.add_child(animation_item)

	animation_item.connect("updated",Callable(self,"_on_animation_data_updated"))
	animation_item.connect("removed",Callable(self,"_on_animation_data_removed"))

	if not is_initial_frame:
		animation_item.connect("highlight_node",Callable(self,"_on_highlight_node"))

	if animation_item.has_signal("select_animation"):
		animation_item.connect("select_animation",Callable(self,"_on_select_animation").bind(animation_item))
		animation_item.connect("select_node_property",Callable(self,"_on_select_node_property"))
		animation_item.connect("select_easing",Callable(self,"_on_select_easing").bind(animation_item))
		animation_item.connect("select_relative_property",Callable(self,"_on_select_relative_property").bind(animation_item))
		animation_item.connect("preview_animation",Callable(self,"_on_preview_animation"))

	animation_item.set_data(node, path)

	return animation_item

func collapse() -> void:
	_collapse_button.set_meta(_DO_NOT_ANIMATE_KEY, true)
	_collapse_button.button_pressed = true

func _animate_me(backwards := false) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)
	
	anima.set_default_duration(0.3)
	anima.set_apply_initial_values(ANIMA.APPLY_INITIAL_VALUES.ON_PLAY)

	anima.with(
		Anima.Node(self) \
			super.anima_animation_frames({
				from = {
					"min_size:x": 0,
					"size:x": 0,
					"opacity": 0,
				},
				to = {
					"min_size:x": _final_width,
					"size:x": _final_width,
					"opacity": 1,
				},
				easing = ANIMA.EASING.EASE_OUT_BACK,
				initial_values = {
					"min_size:x": 0,
					"size:x": 0,
					"opacity": 0,
				}
			})
	) \
	super.with(
		Anima.Nodes([
			get_node("Rectangle/ContentContainer/Rectangle/HBoxContainer/AnimaActionsBGColor/MoveContainer").get_children(),
			get_node("Rectangle/ContentContainer/Rectangle/HBoxContainer/AnimaActionsBGColor2/ActionsContainer").get_children()
		], 0.05) \
		super.anima_animation_frames({
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
		}) \
		super.anima_delay(0.1) 
	) \
	super.skip(
		Anima.Node($Collapse).anima_fade_in().anima_initial_value(0)
	)


	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	await anima.animation_completed

	clip_contents = false

	return anima

func set_is_initial_frame(new_is_initial_frame: bool):
	is_initial_frame = new_is_initial_frame

	find_child("DurationContainer").visible = !is_initial_frame
	find_child("Delete").visible = !is_initial_frame

func set_relative_property(node_path: String, property: String) -> void:
	_source.set_relative_propert(node_path, property)

func _on_Delete_pressed():
	$ConfirmationDialog.popup_centered()

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

func _on_select_node_property(source: Node, path: String) -> void:
	emit_signal("select_node_property", source, path)

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

func _on_Collapse_toggled(toggled: bool) -> void:
	var can_emit_signal = not _collapse_button.has_meta(_DO_NOT_ANIMATE_KEY)
	_is_animating = true

	var anima := Anima.begin_single_shot(self, "collapse")
	var duration = 0.3

	anima.set_default_duration(0.3)

	_frame_collapsed_title.get_child(0).text = _frame_name.get_text()
	_frame_collapsed_title.position.y = size.y

	anima.then(
		Anima.Node(_collapse_button) \
			super.anima_animation_frames({
				to = {
					x = 0,
					y = 0,
					"size:y": "..:size:y",
					easing = ANIMA.EASING.EASE_IN_EXPO,
				},
				relative = []
			})
	) \
	super.with(
		Anima.Node(self) \
			super.anima_animation_frames({
				to = {
					"min_size:x": _collapse_button.size.x,
					"size:x": _collapse_button.size.x,
				},
				easing = ANIMA.EASING.EASE_IN_EXPO
			})
	) \
	super.skip(
		Anima.Node(_collapse_button.get_child(0)).anima_rotate(180, ANIMA.PIVOT.CENTER)
	) \
	super.with(
		Anima.Node(_collapse_button.get_child(0)).anima_fade_out()
	) \
	super.with(
		Anima.Node($Rectangle).anima_fade_out()
	) \
	super.then(
		Anima.Node(_frame_collapsed_title.get_child(0)).anima_animation_frames({
			from = {
				opacity = 0,
				y = -100,
			},
			to = {
				opacity = 1,
				y = 0,
				easing = ANIMA.EASING.EASE_OUT_BACK
			},
			initial_values = {
				y = -100,
			},
			relative = []
		})
	)

	if toggled:
		anima.play()
	else:
		anima.play_backwards_with_speed(1.2)

	await anima.animation_completed

	_is_animating = false

	$Rectangle.minimum_size.x = _final_width
	$Rectangle.size.x = _final_width

	if can_emit_signal:
		emit_signal("frame_updated")
	else:
		_collapse_button.remove_meta(_DO_NOT_ANIMATE_KEY)

func _on_FrameAnimation_item_rect_changed():
	if _old_height == size.y or _is_animating:
		return

	if _collapse_button == null:
		_collapse_button = $Collapse

	_old_height = size.y

	if _collapse_button.pressed:
		_collapse_button.size.y = size.y
	else:
		_collapse_button.position.y = size.y - _collapse_button.size.y - 12

func _on_PlayButton_pressed():
	emit_signal("preview_frame")

func _on_Collapse_mouse_entered():
	$FrameCollapsedTitle.add_theme_color_override("font_color", Color.BLACK)

func _on_Collapse_mouse_exited():
	$FrameCollapsedTitle.add_theme_color_override("font_color", Color.WHITE)

func _on_DefaultFrameDuration_toggled(button_pressed):
	find_child("DurationContainer").visible = button_pressed

func _on_FrameAnimation_gui_input(event):
	pass # Replace with function body.

func _on_AnimationsContainer_node_dragged(node_path: String) -> void:
	emit_signal("add_node", node_path)

func _on_ConfirmationDialog_confirmed():
	if animate_entrance_exit:
		await _animate_me(true).completed

	queue_free()
	emit_signal("frame_deleted")

func _get_data_index() -> int:
	return get_meta("_data_index")

func _on_preview_animation(preview_info: Dictionary) -> void:
	preview_info.frame_id = _get_data_index()

	emit_signal("preview_animation", preview_info)

func _on_Preview_pressed():
	var preview_info := {
		frame_id = _get_data_index(),
		preview_button = find_child("Preview")
	}

	emit_signal("preview_animation", preview_info)

func update_size_x(value: float) -> void:
	minimum_size.x = value
	size.x = value
