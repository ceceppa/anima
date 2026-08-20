class_name DemoCard
extends Button

## A selectable tile in the Demo Selector's category grid — an icon, a title,
## and a one-line description for one playground demo
## (design-brief.md §Component guide "Demo card").

const BG := Color(0.0705882, 0.0941176, 0.14902, 1.0)             # surface
const BORDER := Color(0.117647, 0.160784, 0.231373, 1.0)          # border
const BORDER_ACTIVE := Color(0.654902, 0.545098, 0.980392, 1.0)   # accent-soft
const TITLE_COLOR := Color(0.972549, 0.980392, 0.988235, 1.0)     # text-primary
const DESCRIPTION_COLOR := Color(0.580392, 0.639216, 0.721569, 1.0) # text-secondary

## Static per-card authoring content — set directly on this node in the
## editor Inspector, never assigned imperatively from a parent scene's script
## (project-rules.md §Example Scenes — Editor-Authored Content).
@export var title: String = "":
	set(value):
		title = value
		if is_node_ready():
			_title.text = value

@export var description: String = "":
	set(value):
		description = value
		if is_node_ready():
			_description.text = value

## Icons in this project are line-style Unicode glyphs, not image assets
## (matches example_header.gd's own icon convention). Named `icon_glyph`,
## not `icon` — `Button` (this component's base class) already declares a
## native `icon: Texture2D` export, and redefining it is a parse error.
@export var icon_glyph: String = "":
	set(value):
		icon_glyph = value
		if is_node_ready():
			_icon_label.text = value

@onready var _icon_label: Label = %IconLabel
@onready var _title: Label = %Title
@onready var _description: Label = %Description

func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_ALL

	_title.add_theme_color_override("font_color", TITLE_COLOR)
	_title.add_theme_font_size_override("font_size", 16)
	_description.add_theme_color_override("font_color", DESCRIPTION_COLOR)
	_description.add_theme_font_size_override("font_size", 13)

	_title.text = title
	_description.text = description
	_icon_label.text = icon_glyph

	_apply_style(false)

	mouse_entered.connect(_apply_style.bind(true))
	mouse_exited.connect(_apply_style.bind(false))
	focus_entered.connect(_apply_style.bind(true))
	focus_exited.connect(_apply_style.bind(false))

## Brightens the border to accent-soft on hover/focus — the same selection
## language `Card`/`SelectorButton` already use for every other example
## scene. Never a per-category colour (design-brief.md §Visual direction).
func _apply_style(active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = BG
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = BORDER_ACTIVE if active else BORDER
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	if active:
		style.shadow_color = Color(BORDER_ACTIVE.r, BORDER_ACTIVE.g, BORDER_ACTIVE.b, 0.3)
		style.shadow_size = 8
	for style_name in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(style_name, style)
