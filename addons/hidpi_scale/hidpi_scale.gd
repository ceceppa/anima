class_name HiDPIScale
extends RefCounted

## Applies the operating system's own display scale factor to a control's
## window, so a running example stays legible at the display scale the
## author actually uses. Normal-density displays keep Godot's default scale.
##
## Carries no dependency on Anima or any other addon — reusable on its own
## (project-rules.md §Example Scenes).
static func apply_to(control: Control) -> void:
	var screen := DisplayServer.window_get_current_screen()
	var display_scale := DisplayServer.screen_get_scale(screen)
	if display_scale > 1.0:
		control.get_window().content_scale_factor = display_scale
