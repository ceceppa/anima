class_name SelectorButton
extends Button

const SELECTED_BG := Color(0.309804, 0.27451, 0.898039, 1.0)
const UNSELECTED_BG := Color(0.0705882, 0.0941176, 0.14902, 1.0)
const TEXT_SECONDARY := Color(0.580392, 0.639216, 0.721569, 1.0)

var _selected_style: StyleBoxFlat
var _unselected_style: StyleBoxFlat

func _ready() -> void:
	toggle_mode = true
	_selected_style = _make_style(SELECTED_BG)
	_unselected_style = _make_style(UNSELECTED_BG)
	set_selected(false)

## Corner radius + content margin are this component's one canonical home for
## example-scene button padding — project-rules.md §Example Scenes.
func _make_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
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

	var style := _selected_style if selected else _unselected_style
	for style_name in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(style_name, style)

	var font_color := Color.WHITE if selected else TEXT_SECONDARY
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		add_theme_color_override(color_name, font_color)
