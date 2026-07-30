extends "res://addons/gut/test.gd"

func _make_card() -> StateCard:
	var card: StateCard = preload("res://examples/shared/components/state_card.tscn").instantiate()
	add_child_autofree(card)
	return card

func test_defaults_to_rest_at_zero_progress():
	var card := _make_card()
	assert_eq(card.progress, 0.0)
	assert_eq(card.modulate.a, StateCard.DIM_ALPHA)
	assert_eq(card.scale, Vector2.ONE)

func test_set_label_updates_the_label_text():
	var card := _make_card()
	card.set_label("B")
	assert_eq(card.label.text, "B")

func test_set_progress_zero_matches_rest_look():
	var card := _make_card()
	card.set_progress(0.0)
	assert_eq(card.style_box.border_color, StateCard.BORDER_START)
	assert_eq(card.label.get_theme_color("font_color"), StateCard.LABEL_START)
	assert_eq(card.modulate.a, StateCard.DIM_ALPHA)

func test_set_progress_one_matches_complete_look():
	var card := _make_card()
	card.set_progress(1.0)
	assert_eq(card.style_box.border_color, StateCard.BORDER_END)
	assert_eq(card.label.get_theme_color("font_color"), StateCard.LABEL_END)
	assert_eq(card.modulate.a, 1.0)

func test_set_progress_interpolates_continuously_with_no_discrete_jump():
	var card := _make_card()
	card.set_progress(0.5)
	assert_eq(card.style_box.border_color, StateCard.BORDER_START.lerp(StateCard.BORDER_END, 0.5))
	assert_eq(card.label.get_theme_color("font_color"), StateCard.LABEL_START.lerp(StateCard.LABEL_END, 0.5))
	assert_almost_eq(card.modulate.a, lerpf(StateCard.DIM_ALPHA, 1.0, 0.5), 0.001)

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
