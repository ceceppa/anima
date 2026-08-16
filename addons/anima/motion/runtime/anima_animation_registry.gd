## Backs [method Anima.animation] — a name-to-path lookup for the ported v1
## animation catalog (`tech-spec.md` §Animation catalog). Each entry's `.tres`
## is loaded once and cached, so every later request for the same name
## returns the identical [AnimaMotion] instance — the same object a user gets
## by referencing the `.tres` directly, per this phase's "reachable two ways"
## contract. Internal to [Anima]; not part of the public authoring surface.
class_name AnimaAnimationRegistry
extends RefCounted

## Preset name -> `.tres` path, one entry per ported catalog animation.
## `project-rules.md` §Animation Catalog: filename == this key, one folder per category.
const _PATHS := {
	# Attention
	"bounce": "res://addons/anima/presets/attention/bounce.tres",
	"flash": "res://addons/anima/presets/attention/flash.tres",
	"headshake": "res://addons/anima/presets/attention/headshake.tres",
	"heartbeat": "res://addons/anima/presets/attention/heartbeat.tres",
	"jello": "res://addons/anima/presets/attention/jello.tres",
	"pulse": "res://addons/anima/presets/attention/pulse.tres",
	"rubber_band": "res://addons/anima/presets/attention/rubber_band.tres",
	"shake_x": "res://addons/anima/presets/attention/shake_x.tres",
	"shake_y": "res://addons/anima/presets/attention/shake_y.tres",
	"swing": "res://addons/anima/presets/attention/swing.tres",
	"tada": "res://addons/anima/presets/attention/tada.tres",
	"wobble": "res://addons/anima/presets/attention/wobble.tres",
	# Fading entrances
	"fade_in": "res://addons/anima/presets/entrance/fade_in.tres",
	"fade_in_left": "res://addons/anima/presets/entrance/fade_in_left.tres",
	"fade_in_left_big": "res://addons/anima/presets/entrance/fade_in_left_big.tres",
	"fade_in_right": "res://addons/anima/presets/entrance/fade_in_right.tres",
	"fade_in_right_big": "res://addons/anima/presets/entrance/fade_in_right_big.tres",
	"fade_in_up": "res://addons/anima/presets/entrance/fade_in_up.tres",
	"fade_in_up_big": "res://addons/anima/presets/entrance/fade_in_up_big.tres",
	"fade_in_down": "res://addons/anima/presets/entrance/fade_in_down.tres",
	"fade_in_down_big": "res://addons/anima/presets/entrance/fade_in_down_big.tres",
	"fade_in_top_left": "res://addons/anima/presets/entrance/fade_in_top_left.tres",
	"fade_in_top_right": "res://addons/anima/presets/entrance/fade_in_top_right.tres",
	"fade_in_bottom_left": "res://addons/anima/presets/entrance/fade_in_bottom_left.tres",
	"fade_in_bottom_right": "res://addons/anima/presets/entrance/fade_in_bottom_right.tres",
	"fade_in_small": "res://addons/anima/presets/entrance/fade_in_small.tres",
	# Fading exits
	"fade_out": "res://addons/anima/presets/exit/fade_out.tres",
	"fade_out_left": "res://addons/anima/presets/exit/fade_out_left.tres",
	"fade_out_left_big": "res://addons/anima/presets/exit/fade_out_left_big.tres",
	"fade_out_right": "res://addons/anima/presets/exit/fade_out_right.tres",
	"fade_out_right_big": "res://addons/anima/presets/exit/fade_out_right_big.tres",
	"fade_out_up": "res://addons/anima/presets/exit/fade_out_up.tres",
	"fade_out_up_big": "res://addons/anima/presets/exit/fade_out_up_big.tres",
	"fade_out_down": "res://addons/anima/presets/exit/fade_out_down.tres",
	"fade_out_down_big": "res://addons/anima/presets/exit/fade_out_down_big.tres",
	"fade_out_top_left": "res://addons/anima/presets/exit/fade_out_top_left.tres",
	"fade_out_top_right": "res://addons/anima/presets/exit/fade_out_top_right.tres",
	"fade_out_bottom_left": "res://addons/anima/presets/exit/fade_out_bottom_left.tres",
	"fade_out_bottom_right": "res://addons/anima/presets/exit/fade_out_bottom_right.tres",
	# Bouncing entrances/exits
	"bouncing_in": "res://addons/anima/presets/entrance/bouncing_in.tres",
	"bouncing_in_down": "res://addons/anima/presets/entrance/bouncing_in_down.tres",
	"bouncing_in_left": "res://addons/anima/presets/entrance/bouncing_in_left.tres",
	"bouncing_in_right": "res://addons/anima/presets/entrance/bouncing_in_right.tres",
	"bouncing_in_up": "res://addons/anima/presets/entrance/bouncing_in_up.tres",
	"bounce_out": "res://addons/anima/presets/exit/bounce_out.tres",
	"bounce_out_down": "res://addons/anima/presets/exit/bounce_out_down.tres",
	"bounce_out_left": "res://addons/anima/presets/exit/bounce_out_left.tres",
	"bounce_out_right": "res://addons/anima/presets/exit/bounce_out_right.tres",
	"bounce_out_up": "res://addons/anima/presets/exit/bounce_out_up.tres",
	# Back entrances/exits
	"back_in_down": "res://addons/anima/presets/entrance/back_in_down.tres",
	"back_in_left": "res://addons/anima/presets/entrance/back_in_left.tres",
	"back_in_right": "res://addons/anima/presets/entrance/back_in_right.tres",
	"back_in_up": "res://addons/anima/presets/entrance/back_in_up.tres",
	"back_out_down": "res://addons/anima/presets/exit/back_out_down.tres",
	"back_out_left": "res://addons/anima/presets/exit/back_out_left.tres",
	"back_out_right": "res://addons/anima/presets/exit/back_out_right.tres",
	"back_out_up": "res://addons/anima/presets/exit/back_out_up.tres",
	# Rotating entrances/exits
	"rotate_in": "res://addons/anima/presets/entrance/rotate_in.tres",
	"rotate_in_down_left": "res://addons/anima/presets/entrance/rotate_in_down_left.tres",
	"rotate_in_down_right": "res://addons/anima/presets/entrance/rotate_in_down_right.tres",
	"rotate_in_up_left": "res://addons/anima/presets/entrance/rotate_in_up_left.tres",
	"rotate_in_up_right": "res://addons/anima/presets/entrance/rotate_in_up_right.tres",
	"rotate_out": "res://addons/anima/presets/exit/rotate_out.tres",
	"rotate_out_down_left": "res://addons/anima/presets/exit/rotate_out_down_left.tres",
	"rotate_out_down_right": "res://addons/anima/presets/exit/rotate_out_down_right.tres",
	"rotate_out_up_left": "res://addons/anima/presets/exit/rotate_out_up_left.tres",
	"rotate_out_up_right": "res://addons/anima/presets/exit/rotate_out_up_right.tres",
	# Sliding entrances / slide exits
	"slide_in_left": "res://addons/anima/presets/entrance/slide_in_left.tres",
	"slide_in_right": "res://addons/anima/presets/entrance/slide_in_right.tres",
	"slide_in_up": "res://addons/anima/presets/entrance/slide_in_up.tres",
	"slide_in_down": "res://addons/anima/presets/entrance/slide_in_down.tres",
	"slide_out_left": "res://addons/anima/presets/exit/slide_out_left.tres",
	"slide_out_right": "res://addons/anima/presets/exit/slide_out_right.tres",
	"slide_out_up": "res://addons/anima/presets/exit/slide_out_up.tres",
	"slide_out_down": "res://addons/anima/presets/exit/slide_out_down.tres",
	# Zooming entrances/exits
	"zoom_in": "res://addons/anima/presets/entrance/zoom_in.tres",
	"zoom_in_left": "res://addons/anima/presets/entrance/zoom_in_left.tres",
	"zoom_in_left_big": "res://addons/anima/presets/entrance/zoom_in_left_big.tres",
	"zoom_in_right": "res://addons/anima/presets/entrance/zoom_in_right.tres",
	"zoom_in_right_big": "res://addons/anima/presets/entrance/zoom_in_right_big.tres",
	"zoom_in_up": "res://addons/anima/presets/entrance/zoom_in_up.tres",
	"zoom_in_up_big": "res://addons/anima/presets/entrance/zoom_in_up_big.tres",
	"zoom_in_down": "res://addons/anima/presets/entrance/zoom_in_down.tres",
	"zoom_in_down_big": "res://addons/anima/presets/entrance/zoom_in_down_big.tres",
	"zoom_out": "res://addons/anima/presets/exit/zoom_out.tres",
	"zoom_out_down": "res://addons/anima/presets/exit/zoom_out_down.tres",
	"zoom_out_down_big": "res://addons/anima/presets/exit/zoom_out_down_big.tres",
	"zoom_out_left": "res://addons/anima/presets/exit/zoom_out_left.tres",
	"zoom_out_right": "res://addons/anima/presets/exit/zoom_out_right.tres",
	"zoom_out_up": "res://addons/anima/presets/exit/zoom_out_up.tres",
	# Lightspeed, specials, text
	"light_speed_in_left": "res://addons/anima/presets/entrance/light_speed_in_left.tres",
	"light_speed_in_right": "res://addons/anima/presets/entrance/light_speed_in_right.tres",
	"light_speed_out_left": "res://addons/anima/presets/exit/light_speed_out_left.tres",
	"light_speed_out_right": "res://addons/anima/presets/exit/light_speed_out_right.tres",
	"hinge": "res://addons/anima/presets/special/hinge.tres",
	"jack_in_the_box": "res://addons/anima/presets/special/jack_in_the_box.tres",
	"roll_in": "res://addons/anima/presets/entrance/roll_in.tres",
	"roll_out": "res://addons/anima/presets/exit/roll_out.tres",
	"typewrite": "res://addons/anima/presets/text/typewrite.tres",
}

static var _cache: Dictionary = {}

## Returns the cached, shared [AnimaMotion] for [param name], loading it from
## its `.tres` on first request. `null` and an error for an unregistered name
## (`tech-spec.md` §Animation catalog).
static func get_animation(name: String) -> AnimaMotion:
	if _cache.has(name):
		return _cache[name]

	if not _PATHS.has(name):
		push_error("Anima.animation(): no ported preset named \"%s\"." % name)
		return null

	var motion := load(_PATHS[name]) as AnimaMotion
	if motion == null:
		push_error("Anima.animation(): \"%s\" resolved to \"%s\", which failed to load as an AnimaMotion." % [name, _PATHS[name]])
		return null

	_cache[name] = motion
	return motion
