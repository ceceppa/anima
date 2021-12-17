tool
extends PanelContainer

signal play_animation
signal remove_node
signal hide_content
signal show_content

var _content_visible := true

func hide_play_button() -> void:
	$Container/PlayButton.set_visible(false)

func set_style(style: StyleBoxFlat, selected_style: StyleBoxFlat) -> void:
	add_stylebox_override("panel", style)
	add_stylebox_override("selectedframe", selected_style)

func set_title(title: String) -> void:
	$Container/Title.set_text(title)

func set_tooltip(tooltip: String) -> void:
	$Container/Title.set_tooltip(tooltip)

func set_icon(icon) -> void:
	if icon is String:
		$Container/Icon.set_texture(load(icon))
	else:
		$Container/Icon.set_texture(icon)

func hide_remove_button() -> void:
	$Container/RemoveButton.set_visible(false)

func get_title() -> String:
	return $Container/Title.get_text()

func _on_RemoveButton_pressed():
	emit_signal("remove_node")

func _on_PlayButton_pressed():
	emit_signal("play_animation")

func _on_CollapseButton_pressed():
	_content_visible = !_content_visible

	if _content_visible:
		emit_signal("show_content")
	else:
		emit_signal("hide_content")

func _on_Customise_pressed():
	pass
