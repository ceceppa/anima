@tool
class_name ExampleHeader
extends PanelContainer

const BG := Color(0.0705882, 0.0941176, 0.14902, 1.0)         # surface
const BORDER := Color(0.117647, 0.160784, 0.231373, 1.0)       # border
const BORDER_ACTIVE := Color(0.654902, 0.545098, 0.980392, 1.0) # accent-soft
const ICON_BG := Color(0.309804, 0.27451, 0.898039, 1.0)       # accent
const TITLE_COLOR := Color(0.972549, 0.980392, 0.988235, 1.0)  # text-primary
const SUBTITLE_COLOR := Color(0.580392, 0.639216, 0.721569, 1.0) # text-secondary

## Emitted on back-button press. This component only signals the intent —
## [ExamplePlayground] owns the actual navigation, so this header stays
## testable in isolation with no real scene change as a side effect.
signal back_pressed

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

## Per-scene: whether this header shows the "back to Demo Selector" button.
## The Demo Selector itself leaves this false — there is no screen above it
## (ux-flow.md §Demo Selector "How the user gets back").
@export var show_back_button: bool = false:
	set(value):
		show_back_button = value
		if is_node_ready():
			_back_button.visible = value

@onready var _back_button: Button = %BackButton
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

	_back_button.visible = show_back_button
	_apply_back_button_style(false)
	_back_button.mouse_entered.connect(_apply_back_button_style.bind(true))
	_back_button.mouse_exited.connect(_apply_back_button_style.bind(false))
	_back_button.focus_entered.connect(_apply_back_button_style.bind(true))
	_back_button.focus_exited.connect(_apply_back_button_style.bind(false))
	_back_button.pressed.connect(back_pressed.emit)

	# Exported values are already assigned by the scene loader by this point —
	# apply them now that the @onready labels they target actually exist.
	_title.text = title
	_subtitle.text = subtitle
	_icon_label.text = icon

## Brightens the border to accent-soft on hover/focus — the same selection
## language DemoCard/SelectorButton already use (design-brief.md §Visual direction).
func _apply_back_button_style(active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = BG
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = BORDER_ACTIVE if active else BORDER
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	for style_name in ["normal", "hover", "pressed", "focus"]:
		_back_button.add_theme_stylebox_override(style_name, style)
