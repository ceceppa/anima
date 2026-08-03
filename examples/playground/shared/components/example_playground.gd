class_name ExamplePlayground
extends Control

## Shared root for runnable Anima playground scenes.
##
## It makes a running example use the same readable content scale as the
## operating system display. Playground-specific scripts should call
## [method _ready] on this base class instead of copying display setup.

func _ready() -> void:
	_apply_hidpi_scale()

## Applies the operating system's scale factor to the running window when the
## current display is HiDPI. Normal-density displays keep Godot's default scale.
func _apply_hidpi_scale() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var display_scale := DisplayServer.screen_get_scale(screen)
	if display_scale > 1.0:
		get_window().content_scale_factor = display_scale
