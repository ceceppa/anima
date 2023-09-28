@tool
extends HBoxContainer

signal event_deleted
signal select_animation
signal event_selected(name: String)
signal preview_animation

func set_event_name(name: String) -> void:
	var items = $OptionButton.get_popup().item_count

	for item in items:
		var event_name = $OptionButton.get_item_text(item)

		if name == event_name:
			$OptionButton.select(item)
			break

func set_data(data) -> void:
	if typeof(data) == TYPE_STRING:
		$SelectAnimationButton.set_text(data)


func _on_delete_button_pressed():
	event_deleted.emit()

	queue_free()

func _on_select_animation_button_pressed():
	select_animation.emit()

func _on_option_button_item_selected(index):
	event_selected.emit($OptionButton.get_item_text(index))

func _on_play_button_pressed():
	preview_animation.emit()
