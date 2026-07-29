extends "res://addons/gut/test.gd"

func test_restart_pressed_signal_fires_when_button_is_pressed():
	var controls: PlaybackControls = preload("res://examples/shared/components/playback_controls.tscn").instantiate()
	add_child_autofree(controls)

	watch_signals(controls)
	controls.get_node("%RestartButton").pressed.emit()

	assert_signal_emitted(controls, "restart_pressed")
