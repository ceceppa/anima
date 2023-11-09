@tool
extends VBoxContainer

var EVENT_PICKER = preload("res://addons/anima/ui/NodeEventPicker/NodeEventPicker.tscn")

signal event_deleted
signal select_animation
signal event_selected(name: String)
signal preview_animation
signal option_updated
signal select_node_event

func _ready():
	%Duration.text = str(ANIMA.DEFAULT_DURATION)
	%Options.hide()

func get_data() -> Dictionary:
	return {
		animation = %SelectAnimationButton.text,
		play_mode = %PlayMode.selected,
		delay = float(%Delay.text),
		duration = float(%Duration.text),
	}

func set_event_name(name: String) -> void:
	var items = %OptionButton.get_popup().item_count

	for item in items:
		var event_name = %OptionButton.get_item_text(item)

		if name == event_name:
			%OptionButton.select(item)
			break

func set_data(data) -> void:
	if typeof(data) == TYPE_STRING:
		%SelectAnimationButton.set_text(data)
	else:
		%SelectAnimationButton.set_text(data.animation)
		%PlayMode.select(data.play_mode)
		%Delay.text = str(data.delay)
		%Duration.text = str(data.duration)

func _on_select_animation_button_pressed():
	select_animation.emit()

func _on_option_button_item_selected(index):
	event_selected.emit(%OptionButton.get_item_text(index))

func _on_play_button_pressed():
	preview_animation.emit()

func _on_skip_button_toggled(button_pressed):
	var icon_file = "res://addons/anima/icons/GuiVisibilityVisible.svg"
	
	if button_pressed:
		icon_file = "res://addons/anima/icons/GuiVisibilityHidden.svg"

	%SkipButton.icon = load(icon_file)

func _on_more_button_toggled(button_pressed):
	var icon_file = "res://addons/anima/icons/Closed.svg"
	
	if button_pressed:
		icon_file = "res://addons/anima/icons/Collapse.svg"

	%Options.visible = button_pressed
	%MoreButton.icon = load(icon_file)

func _on_remove_pressed():
	event_deleted.emit()

	queue_free()

func _on_play_method_item_selected(index):
	option_updated.emit()

func _on_delay_text_changed(new_text):
	option_updated.emit()

func _on_duration_text_changed(new_text):
	option_updated.emit()

func _on_on_started_button_pressed():
	select_node_event.emit()
