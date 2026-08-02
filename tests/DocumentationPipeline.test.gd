extends "res://addons/gut/test.gd"

func test_documentation_generator_is_available_from_npm():
	var output: Array = []
	var exit_code := OS.execute("npm", ["run", "docs:api"], output, true)
	assert_eq(exit_code, 0, "documentation generation failed:\n" + "\n".join(output))
	assert_true(FileAccess.file_exists("res://docs/content/docs/anima/anima-group-motion.md"))
