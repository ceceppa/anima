class_name StateCard
extends PanelContainer

const BORDER_START := Color(0.117647, 0.160784, 0.231373, 1.0)
const BORDER_END := Color(0.176471, 0.831373, 0.74902, 1.0)
const LABEL_START := Color(0.580392, 0.639216, 0.721569, 1.0)
const LABEL_END := Color(0.176471, 0.831373, 0.74902, 1.0)
const DIM_ALPHA := 0.5

## The glow (shadow) is animation feedback, not a permanent decoration: it
## rises while the card is actively animating and settles back down once
## complete, rather than climbing to its brightest point exactly when the
## card stops moving.
const GLOW_PEAK_ALPHA := 0.35
const GLOW_SETTLE_ALPHA := 0.10
const GLOW_PEAK_SIZE := 12
const GLOW_SETTLE_SIZE := 4

@onready var label: Label = %Label

var style_box: StyleBoxFlat
var progress: float = 0.0

func _ready() -> void:
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0705882, 0.0941176, 0.14902, 1.0)
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	add_theme_stylebox_override("panel", style_box)

	# Keep the scale pulse in set_progress() centered rather than growing
	# from the default top-left pivot.
	pivot_offset = size / 2.0
	resized.connect(func() -> void: pivot_offset = size / 2.0)

	set_progress(0.0)

func set_label(text: String) -> void:
	label.text = text

## The single visual driver: 0 = at rest (not started), 1 = fully complete.
## Border colour, glow, label colour, brightness, and a small scale pulse all
## come continuously from this one value — there is no discrete state to
## jump between, so nothing snaps at any point along the way, including the
## very end.
func set_progress(t: float) -> void:
	progress = clampf(t, 0.0, 1.0)

	var border := BORDER_START.lerp(BORDER_END, progress)
	style_box.border_color = border

	# A bump that rises from 0 and returns to 0 across the [0, 1] range (peaks
	# around the midpoint), blended toward the small settle value as progress
	# nears 1 — continuous throughout, so nothing snaps at completion either.
	var glow_bump := sin(progress * PI)
	var settle_weight := progress * progress
	var glow_alpha := lerpf(GLOW_PEAK_ALPHA * glow_bump, GLOW_SETTLE_ALPHA, settle_weight)
	var glow_size := lerpf(GLOW_PEAK_SIZE * glow_bump, GLOW_SETTLE_SIZE, settle_weight)
	style_box.shadow_color = Color(border.r, border.g, border.b, glow_alpha)
	style_box.shadow_size = roundi(glow_size)

	label.add_theme_color_override("font_color", LABEL_START.lerp(LABEL_END, progress))

	modulate.a = lerpf(DIM_ALPHA, 1.0, progress)
	var bump := 1.0 + 0.08 * sin(progress * PI)
	scale = Vector2(bump, bump)
