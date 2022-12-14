tool
extends Control

signal animation_updated
signal preview_animation(preview_info)
signal change_editor_position(new_position)
signal add_delay
signal add_frame
signal expand_all
signal collapse_all

onready var _animation_name: Control = find_node("AnimationName")
onready var _visibility_strategy: OptionButton = find_node("VisibilityStrategy")
onready var _default_duration: Control = find_node("DefaultDuration")
onready var _bg_color = find_node("BGColor")

var _is_restoring_data := false

func _ready():
	_on_AnimaAnimation_resized()

func get_data() -> Dictionary:
	if _default_duration == null:
		_animation_name = find_node("AnimationName")
		_visibility_strategy = find_node("VisibilityStrategy")
		_default_duration = find_node("DefaultDuration")
		_bg_color = find_node("BGColor")

	return {
		name = "default", #_animation_name.get_value(),
		visibility_strategy = _visibility_strategy.get_selected_id(),
		default_duration = _default_duration.get_value()
	}

func restore_data(data: Dictionary) -> void:
	_is_restoring_data = true

	if _animation_name == null:
		_animation_name = find_node("AnimationName")
		_visibility_strategy = find_node("VisibilityStrategy")
		_default_duration = find_node("DefaultDuration")

	if data.default_duration == null:
		data.default_duration = ANIMA.DEFAULT_DURATION

#	_animation_name.set_value(data.name)
	_visibility_strategy.select(data.visibility_strategy)
	_default_duration.set_value(data.default_duration)

	_is_restoring_data = false

func _on_value_updated(_ignore = null):
	if not _is_restoring_data:
		emit_signal("animation_updated")

func _on_AnimaButton_pressed():
	var name = find_node("AnimationName").get_value()

	if name == null:
		name = "default"

	emit_signal("play_animation", name)

func _on_PlayButton_pressed():
	emit_signal("preview_animation", { preview_button = find_node("Preview"), name = "default" })

func _on_AnimaAnimation_resized():
	if not _bg_color:
		return

	_bg_color.rect_size = rect_size

func _on_DefaultDuration_changed():
	emit_signal("animation_updated")

func _on_VisibilityStrategy_item_selected(index):
	emit_signal("animation_updated")

func get_selected_animation_name() -> String:
	return "default"

func set_default_editor_position(position) -> void:
	var root: Node = find_node("Positions")

	for child_index in root.get_child_count():
		var child = root.get_child(child_index)

		child.visible = child_index != position


func _on_PositionBottom_pressed():
	emit_signal("change_editor_position", AnimaVisualNode.EDITOR_POSITION.BOTTOM)

func _on_PositionRight_pressed():
	emit_signal("change_editor_position", AnimaVisualNode.EDITOR_POSITION.RIGHT)

func _on_Add_item_selected(id):
	if id == 0:
		emit_signal("add_frame")
	else:
		emit_signal("add_delay")

func _on_ToggleExtra_toggled(button_pressed):
	$Extra.visible = button_pressed

func _on_ExpandAll_pressed():
	emit_signal("expand_all")

func _on_CollapseAll_pressed():
	emit_signal("collapse_all")


func _on_Preview_play_preview():
	emit_signal("preview_animation", { preview_button = find_node("Preview"), name = "default" })
