extends "res://addons/gut/test.gd"

func _make_card() -> Card:
	var card: Card = preload("res://examples/shared/components/card.tscn").instantiate()
	add_child_autofree(card)
	return card

func test_defaults_to_rest_at_zero_progress():
	var card := _make_card()
	assert_eq(card.progress, 0.0)
	assert_eq(card.modulate.a, Card.DIM_ALPHA)
	assert_eq(card.scale, Vector2.ONE)

func test_atlas_index_selects_a_region_from_the_shared_artwork():
	var card := _make_card()
	card.atlas_index = 5
	var atlas := card.artwork.texture as AtlasTexture
	assert_eq(atlas.region, Rect2(384, 341, 384, 341))
	assert_null(card.get_node_or_null("MarginContainer/Label"))

func test_set_progress_zero_matches_rest_look():
	var card := _make_card()
	card.set_progress(0.0)
	assert_eq(card.style_box.border_color, Card.BORDER_START)
	assert_eq(card.modulate.a, Card.DIM_ALPHA)

func test_set_progress_one_matches_complete_look():
	var card := _make_card()
	card.set_progress(1.0)
	assert_eq(card.style_box.border_color, Card.BORDER_END)
	assert_eq(card.modulate.a, 1.0)

func test_set_progress_interpolates_continuously_with_no_discrete_jump():
	var card := _make_card()
	card.set_progress(0.5)
	assert_eq(card.style_box.border_color, Card.BORDER_START.lerp(Card.BORDER_END, 0.5))
	assert_almost_eq(card.modulate.a, lerpf(Card.DIM_ALPHA, 1.0, 0.5), 0.001)

func test_glow_is_absent_at_rest():
	var card := _make_card()
	card.set_progress(0.0)
	assert_eq(card.style_box.shadow_size, 0)
	assert_eq(card.style_box.shadow_color.a, 0.0)

func test_glow_peaks_mid_animation_and_settles_down_once_complete():
	var card := _make_card()

	card.set_progress(0.0)
	var start_alpha := card.style_box.shadow_color.a

	card.set_progress(0.5)
	var mid_alpha := card.style_box.shadow_color.a
	var mid_size := card.style_box.shadow_size

	card.set_progress(1.0)
	var end_alpha := card.style_box.shadow_color.a
	var end_size := card.style_box.shadow_size

	assert_gt(mid_alpha, start_alpha, "glow should be stronger mid-animation than before it starts")
	assert_gt(mid_alpha, end_alpha, "glow should be stronger mid-animation than once it settles")
	assert_gt(mid_size, end_size, "glow size should shrink back down once settled, not stay at its peak")

func test_set_progress_clamps_out_of_range_values():
	var card := _make_card()

	card.set_progress(-1.0)
	assert_eq(card.progress, 0.0)

	card.set_progress(2.0)
	assert_eq(card.progress, 1.0)
