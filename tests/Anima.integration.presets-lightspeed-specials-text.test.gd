extends "res://addons/gut/test.gd"

## Lightspeed, special, and text presets, plus the phase-17 full-catalog
## and access-path checks (phase-17, story-9 — the closing story).

func _control() -> Control:
	var node := Control.new()
	add_child_autofree(node)
	node.size = Vector2(80.0, 40.0)
	node.position = Vector2(50.0, 60.0)
	return node

## light_speed targets Sprite2D (a Node2D, so it has a writable "transform"
## for the skew) with a fixed literal pixel offset, not a size-dependent one
## — AnimaValue.custom() doesn't survive .tres serialization (tech-spec.md
## §Animation catalog).
func _sprite() -> Sprite2D:
	var node := Sprite2D.new()
	add_child_autofree(node)
	node.position = Vector2(50.0, 60.0)
	return node

func test_light_speed_in_left_starts_transparent_offset_and_skewed_ends_opaque_at_rest_and_unskewed():
	var node := _sprite()
	var motion := Anima.animation("light_speed_in_left")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 - 1000.0, 0.01)
	assert_false(is_zero_approx(node.transform.x.y))
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.transform.x.y, 0.0, 0.01)

func test_light_speed_out_right_starts_opaque_at_rest_unskewed_ends_transparent_offset_and_skewed():
	var node := _sprite()
	var motion := Anima.animation("light_speed_out_right")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 + 1000.0, 0.01)
	assert_false(is_zero_approx(node.transform.x.y))

func test_hinge_drops_and_fades_below_rest():
	var node := _control()
	var motion := Anima.animation("hinge")
	assert_eq(motion.default_pivot, AnimaPivot.Kind.TOP_LEFT)
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.y, 60.0 + 700.0, 0.01)

func test_jack_in_the_box_settles_at_normal_scale_and_upright():
	var node := _control()
	var motion := Anima.animation("jack_in_the_box")
	assert_eq(motion.default_pivot, AnimaPivot.Kind.BOTTOM_CENTER)
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.1, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_roll_in_starts_offset_rotated_and_transparent_ends_at_rest_and_upright():
	var node := _control()
	var motion := Anima.animation("roll_in")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 - 80.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_roll_out_ends_offset_rotated_and_transparent():
	var node := _control()
	var motion := Anima.animation("roll_out")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 + 80.0, 0.01)
	assert_false(is_zero_approx(node.rotation))

func test_typewrite_reveals_progressively_with_an_explicit_fixed_duration():
	var label := RichTextLabel.new()
	add_child_autofree(label)
	var motion := Anima.animation("typewrite")
	assert_true(motion.duration > 0.0)
	var instance = motion.create_runtime()
	instance.advance(label, 0.0)
	assert_almost_eq(label.visible_ratio, 0.0, 0.01)
	instance.advance(label, motion.duration)
	assert_almost_eq(label.visible_ratio, 1.0, 0.01)

## --- Full-catalog check: every v1 source animation has a ported preset ---

func test_full_catalog_all_99_presets_are_registered():
	var names := [
		"bounce", "flash", "headshake", "heartbeat", "jello", "pulse", "rubber_band", "shake_x", "shake_y", "swing", "tada", "wobble",
		"fade_in", "fade_in_left", "fade_in_left_big", "fade_in_right", "fade_in_right_big", "fade_in_up", "fade_in_up_big",
		"fade_in_down", "fade_in_down_big", "fade_in_top_left", "fade_in_top_right", "fade_in_bottom_left", "fade_in_bottom_right", "fade_in_small",
		"fade_out", "fade_out_left", "fade_out_left_big", "fade_out_right", "fade_out_right_big", "fade_out_up", "fade_out_up_big",
		"fade_out_down", "fade_out_down_big", "fade_out_top_left", "fade_out_top_right", "fade_out_bottom_left", "fade_out_bottom_right",
		"bouncing_in", "bouncing_in_down", "bouncing_in_left", "bouncing_in_right", "bouncing_in_up",
		"bounce_out", "bounce_out_down", "bounce_out_left", "bounce_out_right", "bounce_out_up",
		"back_in_down", "back_in_left", "back_in_right", "back_in_up",
		"back_out_down", "back_out_left", "back_out_right", "back_out_up",
		"rotate_in", "rotate_in_down_left", "rotate_in_down_right", "rotate_in_up_left", "rotate_in_up_right",
		"rotate_out", "rotate_out_down_left", "rotate_out_down_right", "rotate_out_up_left", "rotate_out_up_right",
		"slide_in_left", "slide_in_right", "slide_in_up", "slide_in_down",
		"slide_out_left", "slide_out_right", "slide_out_up", "slide_out_down",
		"zoom_in", "zoom_in_left", "zoom_in_left_big", "zoom_in_right", "zoom_in_right_big",
		"zoom_in_up", "zoom_in_up_big", "zoom_in_down", "zoom_in_down_big",
		"zoom_out", "zoom_out_down", "zoom_out_down_big", "zoom_out_left", "zoom_out_right", "zoom_out_up",
		"light_speed_in_left", "light_speed_in_right", "light_speed_out_left", "light_speed_out_right",
		"hinge", "jack_in_the_box", "roll_in", "roll_out",
		"typewrite",
	]
	assert_eq(names.size(), 99, "expected exactly 99 catalog names in this check")
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_every_category_has_at_least_one_preset():
	var categories := [
		"attention_seeker", "back_entrances", "back_exits", "bouncing_entrances", "bouncing_exits",
		"fading_entrances", "fading_exits", "lightspeed", "rotating_entrances", "rotating_exits",
		"slide_exits", "sliding_entrances", "specials", "text", "zooming_entrances", "zooming_exits",
	]
	for category in categories:
		var dir := DirAccess.open("res://addons/anima/presets/%s" % category)
		assert_not_null(dir, "missing category folder: %s" % category)
		var found := false
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				found = true
				break
			file_name = dir.get_next()
		assert_true(found, "category has no presets: %s" % category)

## --- Access-path check: by-name and by-asset stay consistent phase-wide ---

func test_by_name_and_by_asset_are_consistent_across_every_story():
	var cases := {
		"tada": "res://addons/anima/presets/attention_seeker/tada.tres",
		"fade_in_left": "res://addons/anima/presets/fading_entrances/fade_in_left.tres",
		"bounce_out": "res://addons/anima/presets/bouncing_exits/bounce_out.tres",
		"back_in_down": "res://addons/anima/presets/back_entrances/back_in_down.tres",
		"rotate_out": "res://addons/anima/presets/rotating_exits/rotate_out.tres",
		"slide_in_left": "res://addons/anima/presets/sliding_entrances/slide_in_left.tres",
		"zoom_out": "res://addons/anima/presets/zooming_exits/zoom_out.tres",
		"hinge": "res://addons/anima/presets/specials/hinge.tres",
		"typewrite": "res://addons/anima/presets/text/typewrite.tres",
	}
	for preset_name in cases:
		var by_name := Anima.animation(preset_name)
		var by_asset := load(cases[preset_name])
		assert_same(by_name, by_asset, "%s by-name/by-asset identity" % preset_name)
