extends "res://addons/gut/test.gd"

func test_documentation_generator_is_available_from_npm():
	var output: Array = []
	var exit_code := OS.execute("npm", ["run", "docs:api"], output, true)
	assert_eq(exit_code, 0, "documentation generation failed:\n" + "\n".join(output))
	assert_true(FileAccess.file_exists("res://docs/content/docs/anima/anima-group-motion.md"))

func test_a_later_property_page_section_does_not_repeat_an_earlier_propertys_comment():
	var output: Array = []
	OS.execute("npm", ["run", "docs:api"], output, true)

	var content := FileAccess.get_file_as_string("res://docs/content/docs/anima/anima-grid-motion.md")
	var start_point_section := content.get_slice("### start_point", 1).get_slice("### distance_formula", 0)

	assert_false(start_point_section.contains("Both must be positive"), "start_point's documentation section should not repeat grid_dimensions' comment")
	assert_true(start_point_section.contains("distance_formula] measures distance"), "start_point's own comment should still be present")
