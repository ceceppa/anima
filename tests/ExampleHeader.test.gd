extends "res://addons/gut/test.gd"

func _make_header() -> ExampleHeader:
	var header: ExampleHeader = preload("res://examples/playground/shared/components/example_header.tscn").instantiate()
	add_child_autofree(header)
	return header

func test_title_export_updates_the_title_text():
	var header := _make_header()
	header.title = "Composition"
	assert_eq(header.get_node("%Title").text, "Composition")

func test_subtitle_export_updates_the_subtitle_text():
	var header := _make_header()
	header.subtitle = "Combine simple animations into expressive flows."
	assert_eq(header.get_node("%Subtitle").text, "Combine simple animations into expressive flows.")

func test_icon_export_updates_the_icon_glyph():
	var header := _make_header()
	header.icon = "✦"
	assert_eq(header.get_node("%IconLabel").text, "✦")

func test_exported_values_apply_when_set_before_the_node_enters_the_tree():
	var header: ExampleHeader = preload("res://examples/playground/shared/components/example_header.tscn").instantiate()
	header.title = "Composition"
	header.subtitle = "Combine simple animations into expressive flows."
	header.icon = "✦"
	add_child_autofree(header)

	assert_eq(header.get_node("%Title").text, "Composition")
	assert_eq(header.get_node("%Subtitle").text, "Combine simple animations into expressive flows.")
	assert_eq(header.get_node("%IconLabel").text, "✦")

func test_back_button_is_hidden_by_default():
	var header := _make_header()
	assert_false(header.get_node("%BackButton").visible)

func test_show_back_button_export_reveals_the_back_button():
	var header := _make_header()
	header.show_back_button = true
	assert_true(header.get_node("%BackButton").visible)

func test_back_button_defaults_to_unselected_border():
	var header := _make_header()
	var style: StyleBoxFlat = header.get_node("%BackButton").get_theme_stylebox("normal")

	assert_eq(style.border_color, ExampleHeader.BORDER)

func test_back_button_hover_brightens_the_border_and_exit_restores_it():
	var header := _make_header()
	var back_button: Button = header.get_node("%BackButton")

	back_button.mouse_entered.emit()
	assert_eq(back_button.get_theme_stylebox("normal").border_color, ExampleHeader.BORDER_ACTIVE)

	back_button.mouse_exited.emit()
	assert_eq(back_button.get_theme_stylebox("normal").border_color, ExampleHeader.BORDER)

func test_pressing_the_back_button_emits_back_pressed():
	var header := _make_header()
	watch_signals(header)

	header.get_node("%BackButton").pressed.emit()

	assert_signal_emitted(header, "back_pressed")
