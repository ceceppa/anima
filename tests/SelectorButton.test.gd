extends "res://addons/gut/test.gd"

func _make_button() -> SelectorButton:
	var button: SelectorButton = preload("res://examples/shared/components/selector_button.tscn").instantiate()
	add_child_autofree(button)
	return button

func test_defaults_to_unselected():
	var button := _make_button()
	assert_false(button.button_pressed)

func test_set_selected_true_applies_selected_style_and_white_text():
	var button := _make_button()
	button.set_selected(true)

	assert_true(button.button_pressed)
	assert_eq(button.get_theme_stylebox("normal").bg_color, SelectorButton.SELECTED_BG)
	assert_eq(button.get_theme_color("font_color"), Color.WHITE)

func test_set_selected_false_applies_unselected_style_and_secondary_text():
	var button := _make_button()
	button.set_selected(true)
	button.set_selected(false)

	assert_false(button.button_pressed)
	assert_eq(button.get_theme_stylebox("normal").bg_color, SelectorButton.UNSELECTED_BG)
	assert_eq(button.get_theme_color("font_color"), SelectorButton.TEXT_SECONDARY)

func test_style_has_the_shared_button_padding():
	var button := _make_button()
	var style: StyleBoxFlat = button.get_theme_stylebox("normal")

	assert_eq(style.content_margin_left, 24.0)
	assert_eq(style.content_margin_right, 24.0)
	assert_eq(style.content_margin_top, 12.0)
	assert_eq(style.content_margin_bottom, 12.0)
