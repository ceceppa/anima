extends "res://addons/gut/test.gd"

func test_categories_returns_the_sixteen_v1_mirrored_categories_alphabetically():
	assert_eq(AnimationCatalogIndex.categories(), [
		"attention_seeker", "back_entrances", "back_exits", "bouncing_entrances", "bouncing_exits",
		"fading_entrances", "fading_exits", "lightspeed", "rotating_entrances", "rotating_exits",
		"slide_exits", "sliding_entrances", "specials", "text", "zooming_entrances", "zooming_exits",
	])

func test_names_returns_every_attention_seeker_preset_alphabetically():
	var names := AnimationCatalogIndex.names("attention_seeker")
	assert_eq(names.size(), 12)
	var sorted_copy := names.duplicate()
	sorted_copy.sort()
	assert_eq(names, sorted_copy)
	assert_true(names.has("bounce"))
	assert_true(names.has("wobble"))

func test_names_count_matches_each_category_size():
	assert_eq(AnimationCatalogIndex.names("attention_seeker").size(), 12)
	assert_eq(AnimationCatalogIndex.names("back_entrances").size(), 4)
	assert_eq(AnimationCatalogIndex.names("back_exits").size(), 4)
	assert_eq(AnimationCatalogIndex.names("bouncing_entrances").size(), 5)
	assert_eq(AnimationCatalogIndex.names("bouncing_exits").size(), 5)
	assert_eq(AnimationCatalogIndex.names("fading_entrances").size(), 14)
	assert_eq(AnimationCatalogIndex.names("fading_exits").size(), 13)
	assert_eq(AnimationCatalogIndex.names("lightspeed").size(), 4)
	assert_eq(AnimationCatalogIndex.names("rotating_entrances").size(), 5)
	assert_eq(AnimationCatalogIndex.names("rotating_exits").size(), 5)
	assert_eq(AnimationCatalogIndex.names("slide_exits").size(), 4)
	assert_eq(AnimationCatalogIndex.names("sliding_entrances").size(), 4)
	assert_eq(AnimationCatalogIndex.names("specials").size(), 4)
	assert_eq(AnimationCatalogIndex.names("text").size(), 1)
	assert_eq(AnimationCatalogIndex.names("zooming_entrances").size(), 9)
	assert_eq(AnimationCatalogIndex.names("zooming_exits").size(), 6)

func test_names_with_unknown_category_returns_empty_and_reports_error():
	assert_eq(AnimationCatalogIndex.names("not_a_category"), [])
	assert_push_error("no category")
