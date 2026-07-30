class_name SelectorButton
extends Button

const SELECTED_TEXT := Color(1.0, 1.0, 1.0, 1.0)
const UNSELECTED_TEXT := Color(0.580392, 0.639216, 0.721569, 1.0)
const FOCUS_BORDER := Color(0.580392, 0.639216, 0.721569, 1.0)

func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_ALL
	pivot_offset = size / 2.0
	resized.connect(func() -> void: pivot_offset = size / 2.0)

	var padded_style := _make_padded_style()
	for style_name in ["normal", "hover", "pressed"]:
		add_theme_stylebox_override(style_name, padded_style)
	add_theme_stylebox_override("focus", _make_focus_style())

	button_down.connect(func() -> void: scale = Vector2(0.96, 0.96))
	button_up.connect(func() -> void: scale = Vector2.ONE)

	set_selected(false)

## No background fill of its own — this button only ever changes label
## colour/weight. The selected-state background is a single shared indicator
## owned by the enclosing SelectorDock, not each button (project-rules.md
## §Example Scenes).
func _make_padded_style() -> StyleBoxEmpty:
	var style := StyleBoxEmpty.new()
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

## Keyboard focus is visually distinct from selection — an outline, not a fill.
func _make_focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = FOCUS_BORDER
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func set_selected(selected: bool) -> void:
	button_pressed = selected

	var font_color := SELECTED_TEXT if selected else UNSELECTED_TEXT
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		add_theme_color_override(color_name, font_color)
