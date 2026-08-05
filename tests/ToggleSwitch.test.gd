extends "res://addons/gut/test.gd"

func test_defaults_to_off():
	var toggle: ToggleSwitch = preload("res://examples/playground/shared/components/toggle_switch.tscn").instantiate()
	add_child_autofree(toggle)

	assert_false(toggle.enabled)

func test_setting_enabled_emits_toggled():
	var toggle: ToggleSwitch = preload("res://examples/playground/shared/components/toggle_switch.tscn").instantiate()
	add_child_autofree(toggle)

	watch_signals(toggle)
	toggle.enabled = true

	assert_signal_emitted_with_parameters(toggle, "toggled", [true])

func test_setting_the_same_value_again_does_not_re_emit():
	var toggle: ToggleSwitch = preload("res://examples/playground/shared/components/toggle_switch.tscn").instantiate()
	add_child_autofree(toggle)
	toggle.enabled = true

	watch_signals(toggle)
	toggle.enabled = true

	assert_signal_not_emitted(toggle, "toggled")

func test_mouse_click_toggles_state():
	var toggle: ToggleSwitch = preload("res://examples/playground/shared/components/toggle_switch.tscn").instantiate()
	add_child_autofree(toggle)

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	toggle._on_gui_input(event)

	assert_true(toggle.enabled)
