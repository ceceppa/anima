extends "res://addons/gut/test.gd"

func test_restart_pressed_signal_fires_when_button_is_pressed():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	watch_signals(controls)
	controls.get_node("%RestartButton").pressed.emit()

	assert_signal_emitted(controls, "restart_pressed")

func _fill_style(button: Button) -> StyleBoxFlat:
	var style: StyleBox = button.get_theme_stylebox("normal")
	assert_true(style is StyleBoxFlat, "the button's fill should be a flat StyleBoxFlat, not a gradient/StyleBoxTexture")
	return style as StyleBoxFlat

func test_restart_and_reverse_buttons_use_a_flat_fill_with_a_border():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	var restart_button: Button = controls.get_node("%RestartButton")
	var reverse_button: Button = controls.get_node("%ReverseButton")

	var restart_style := _fill_style(restart_button)
	var reverse_style := _fill_style(reverse_button)

	assert_eq(restart_style.bg_color, Color(0.486275, 0.227451, 0.929412), "fill should be flat accent #7C3AED")
	assert_eq(restart_style.border_color, Color(0.654902, 0.545098, 0.980392), "border should be accent-soft #A78BFA")
	assert_eq(restart_style.border_width_left, 2)
	assert_eq(restart_style.border_width_top, 2)
	assert_eq(restart_style.border_width_right, 2)
	assert_eq(restart_style.border_width_bottom, 2)

	assert_eq(restart_style.bg_color, reverse_style.bg_color, "restart and reverse should use the identical fill — neither more prominent than the other")
	assert_eq(restart_style.border_color, reverse_style.border_color)

## No glow: dropped for reading as visual noise (design-brief.md §Component
## guide "Playback controls") — the flat fill and border carry the
## definition alone now.

func test_restart_and_reverse_buttons_are_square_and_equally_sized():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	var restart_button: Button = controls.get_node("%RestartButton")
	var reverse_button: Button = controls.get_node("%ReverseButton")

	assert_eq(restart_button.custom_minimum_size.x, restart_button.custom_minimum_size.y, "a circular button should be authored square")
	assert_eq(restart_button.custom_minimum_size, reverse_button.custom_minimum_size, "restart and reverse should be the same size — neither more prominent than the other")

func test_complete_pressed_signal_fires_when_button_is_pressed():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	watch_signals(controls)
	controls.get_node("%CompleteButton").pressed.emit()

	assert_signal_emitted(controls, "complete_pressed")

func test_revert_pressed_signal_fires_when_button_is_pressed():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	watch_signals(controls)
	controls.get_node("%RevertButton").pressed.emit()

	assert_signal_emitted(controls, "revert_pressed")

func test_speed_dock_defaults_to_1x_and_emits_the_selected_speed():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)
	await get_tree().process_frame # SelectorDock.select()'s first call awaits a frame

	var dock: SelectorDock = controls.get_node("%SpeedDock")
	assert_eq(dock.get_item_count(), 3)
	assert_eq(dock.selected_index, PlaybackControls.DEFAULT_SPEED_INDEX)

	watch_signals(controls)
	dock.get_item(2).pressed.emit()

	assert_signal_emitted_with_parameters(controls, "speed_selected", [2.0])
	assert_eq(dock.selected_index, 2, "pressing a speed button should visually select it")

func test_reduced_motion_toggle_emits_when_toggled():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	var toggle: ToggleSwitch = controls.get_node("%ReducedMotionToggle")
	assert_false(toggle.enabled, "reduced motion should default off")

	watch_signals(controls)
	toggle.enabled = true

	assert_signal_emitted_with_parameters(controls, "reduced_motion_toggled", [true])

func test_restart_and_reverse_buttons_use_real_icon_artwork_not_text_glyphs():
	var controls: PlaybackControls = preload("res://examples/playground/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	var restart_button: Button = controls.get_node("%RestartButton")
	var reverse_button: Button = controls.get_node("%ReverseButton")

	assert_eq(restart_button.text, "", "restart should use icon artwork, not a text glyph")
	assert_eq(reverse_button.text, "", "reverse should use icon artwork, not a text glyph")
	assert_not_null(restart_button.icon, "restart should have icon artwork assigned")
	assert_not_null(reverse_button.icon, "reverse should have icon artwork assigned")
	assert_ne(restart_button.icon, reverse_button.icon, "restart and reverse should use their own distinct artwork")
