## Pill-shaped on/off switch — design-brief.md §Component guide "ToggleSwitch":
## 40×22px track, 18px thumb inset 2px. State changes are an immediate snap,
## not an eased slide (this is a settings switch, not an animated demo
## subject). Drawn directly via _draw(), the same technique SelectorDock's
## own sliding indicator already uses, rather than child Panel nodes.
class_name ToggleSwitch
extends Control

signal toggled(enabled: bool)

const TRACK_SIZE := Vector2(40.0, 22.0)
const THUMB_RADIUS := 9.0
const THUMB_INSET := 2.0

const TRACK_OFF := Color(0.0666667, 0.0941176, 0.164706, 1.0) # surface
const TRACK_OFF_BORDER := Color(0.149412, 0.196078, 0.290196, 1.0) # border
const TRACK_ON := Color(0.486275, 0.227451, 0.929412, 1.0) # accent
const THUMB_OFF := Color(0.658824, 0.705882, 0.8, 1.0) # text-secondary
const THUMB_ON := Color(0.972549, 0.980392, 0.988235, 1.0) # text-primary

## Current on/off state. Setting it directly (not only via user input) also
## redraws and emits [signal toggled], so callers can drive it programmatically.
var enabled: bool = false:
	set(value):
		if enabled == value:
			return
		enabled = value
		queue_redraw()
		toggled.emit(enabled)

func _ready() -> void:
	custom_minimum_size = TRACK_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		enabled = not enabled
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		enabled = not enabled

func _draw() -> void:
	var track_style := StyleBoxFlat.new()
	track_style.corner_radius_top_left = 11
	track_style.corner_radius_top_right = 11
	track_style.corner_radius_bottom_right = 11
	track_style.corner_radius_bottom_left = 11

	if enabled:
		track_style.bg_color = TRACK_ON
	else:
		track_style.bg_color = TRACK_OFF
		track_style.border_width_left = 1
		track_style.border_width_top = 1
		track_style.border_width_right = 1
		track_style.border_width_bottom = 1
		track_style.border_color = TRACK_OFF_BORDER

	draw_style_box(track_style, Rect2(Vector2.ZERO, TRACK_SIZE))

	var thumb_x := (TRACK_SIZE.x - THUMB_INSET - THUMB_RADIUS * 2.0) if enabled else THUMB_INSET
	var thumb_color := THUMB_ON if enabled else THUMB_OFF
	draw_circle(Vector2(thumb_x + THUMB_RADIUS, TRACK_SIZE.y / 2.0), THUMB_RADIUS, thumb_color)
