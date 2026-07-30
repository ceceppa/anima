extends "res://addons/gut/test.gd"

func _make_header() -> ExampleHeader:
	var header: ExampleHeader = preload("res://examples/shared/components/example_header.tscn").instantiate()
	add_child_autofree(header)
	return header

func test_title_export_updates_the_title_text():
	var header := _make_header()
	header.title = "Composition"
	assert_eq(header.get_node("%Title").text, "Composition")

func test_subtitle_export_updates_the_subtitle_text():
	var header := _make_header()
	header.subtitle = "Combine simple animations into expressive flows."
	assert_eq(header.get_node("%Subtitle").text, "Combine simple animations into expressive flows.")

func test_icon_export_updates_the_icon_glyph():
	var header := _make_header()
	header.icon = "✦"
	assert_eq(header.get_node("%IconLabel").text, "✦")

func test_exported_values_apply_when_set_before_the_node_enters_the_tree():
	var header: ExampleHeader = preload("res://examples/shared/components/example_header.tscn").instantiate()
	header.title = "Composition"
	header.subtitle = "Combine simple animations into expressive flows."
	header.icon = "✦"
	add_child_autofree(header)

	assert_eq(header.get_node("%Title").text, "Composition")
	assert_eq(header.get_node("%Subtitle").text, "Combine simple animations into expressive flows.")
	assert_eq(header.get_node("%IconLabel").text, "✦")
