extends "res://addons/gut/test.gd"

func _make_button() -> SelectorButton:
	var button: SelectorButton = preload("res://examples/shared/components/selector_button.tscn").instantiate()
	add_child_autofree(button)
	return button

func test_defaults_to_unselected():
	var button := _make_button()
	assert_false(button.button_pressed)
	assert_eq(button.get_theme_color("font_color"), SelectorButton.UNSELECTED_TEXT)

func test_set_selected_true_applies_white_text_with_no_background_fill():
	var button := _make_button()
	button.set_selected(true)

	assert_true(button.button_pressed)
	assert_eq(button.get_theme_color("font_color"), SelectorButton.SELECTED_TEXT)
	assert_true(button.get_theme_stylebox("normal") is StyleBoxEmpty, "the button must not render its own background fill — the enclosing SelectorDock owns the shared indicator")

func test_set_selected_false_applies_secondary_text():
	var button := _make_button()
	button.set_selected(true)
	button.set_selected(false)

	assert_false(button.button_pressed)
	assert_eq(button.get_theme_color("font_color"), SelectorButton.UNSELECTED_TEXT)

func test_style_has_the_shared_button_padding():
	var button := _make_button()
	var style: StyleBox = button.get_theme_stylebox("normal")

	assert_eq(style.content_margin_left, 24.0)
	assert_eq(style.content_margin_right, 24.0)
	assert_eq(style.content_margin_top, 12.0)
	assert_eq(style.content_margin_bottom, 12.0)

func test_press_feedback_scales_down_while_pressed_and_returns_after_release():
	var button := _make_button()
	button.button_down.emit()
	assert_eq(button.scale, Vector2(0.96, 0.96))
	button.button_up.emit()
	assert_eq(button.scale, Vector2.ONE)

func test_focus_style_is_an_outline_distinct_from_selected_fill():
	var button := _make_button()
	var focus_style: StyleBoxFlat = button.get_theme_stylebox("focus")

	assert_gt(focus_style.border_width_left, 0, "focus must render as a visible outline")
	assert_eq(focus_style.bg_color.a, 0.0, "focus must not fill the background like the selected indicator")
