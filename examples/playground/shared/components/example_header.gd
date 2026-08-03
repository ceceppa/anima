@tool
class_name ExampleHeader
extends PanelContainer

const BG := Color(0.0705882, 0.0941176, 0.14902, 1.0)         # surface
const BORDER := Color(0.117647, 0.160784, 0.231373, 1.0)       # border
const ICON_BG := Color(0.309804, 0.27451, 0.898039, 1.0)       # accent
const TITLE_COLOR := Color(0.972549, 0.980392, 0.988235, 1.0)  # text-primary
const SUBTITLE_COLOR := Color(0.580392, 0.639216, 0.721569, 1.0) # text-secondary

## Static per-scene authoring content — set directly on this node in the
## editor Inspector, never assigned imperatively from a parent scene's script
## (project-rules.md §Example Scenes — Editor-Authored Content).
@export var title: String = "":
	set(value):
		title = value
		if is_node_ready():
			_title.text = value

@export var subtitle: String = "":
	set(value):
		subtitle = value
		if is_node_ready():
			_subtitle.text = value

## Icons in this project are line-style Unicode glyphs (matches the existing
## restart icon in playback_controls.tscn), not image assets.
@export var icon: String = "":
	set(value):
		icon = value
		if is_node_ready():
			_icon_label.text = value

@onready var _icon_box: PanelContainer = %IconBox
@onready var _icon_label: Label = %IconLabel
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle

func _ready() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BG
	panel_style.border_width_bottom = 1
	panel_style.border_color = BORDER
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	panel_style.shadow_size = 8
	panel_style.content_margin_left = 32
	panel_style.content_margin_right = 32
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24
	add_theme_stylebox_override("panel", panel_style)

	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = ICON_BG
	icon_style.corner_radius_top_left = 12
	icon_style.corner_radius_top_right = 12
	icon_style.corner_radius_bottom_right = 12
	icon_style.corner_radius_bottom_left = 12
	_icon_box.add_theme_stylebox_override("panel", icon_style)

	_title.add_theme_color_override("font_color", TITLE_COLOR)
	_title.add_theme_font_size_override("font_size", 28)
	_subtitle.add_theme_color_override("font_color", SUBTITLE_COLOR)
	_subtitle.add_theme_font_size_override("font_size", 14)

	# Exported values are already assigned by the scene loader by this point —
	# apply them now that the @onready labels they target actually exist.
	_title.text = title
	_subtitle.text = subtitle
	_icon_label.text = icon
