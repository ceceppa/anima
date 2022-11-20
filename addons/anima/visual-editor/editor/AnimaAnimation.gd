tool
extends Control

signal animation_updated
signal play_animation(name)

onready var _animation_name: Control = find_node("AnimationName")
onready var _visibility_strategy: OptionButton = find_node("VisibilityStrategy")
onready var _default_duration: Control = find_node("DefaultDuration")

var _is_restoring_data := false

func _ready():
	rect_position = Vector2.ZERO
	pass

func get_data() -> Dictionary:
	return {
		name = _animation_name.get_value(),
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

	_animation_name.set_value(data.name)
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
	emit_signal("play_animation", "default")
