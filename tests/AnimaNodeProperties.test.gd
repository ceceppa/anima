extends "res://addons/gut/test.gd"

func test_extract_shader_params():
	var material = ShaderMaterial.new()
	
	material.shader = load("res://tests/Control.gdshader")

	var props = AnimaNodesProperties.extract_shader_params(material.shader.code)

	assert_eq_deep(props,
	[
		{ name = "speed", type = TYPE_REAL, default = 10.0 },
		{ name = "v2", type = TYPE_VECTOR2, default = Vector2(1.3, 0.3) },
		{ name = "v2_1", type = TYPE_VECTOR2, default = Vector2(1.3, 1.3) },
		{ name = "v3", type = TYPE_VECTOR3, default = Vector3(1.9, 1.9, 1.9) },
		{ name = "v3_1", type = TYPE_VECTOR3, default = Vector3(1.3, 3.0, 0.5) },
		{ name = "c", type = TYPE_COLOR, default = Color(1.0, 1.0, 1.0, 1.0) },
		{ name = "c_1", type = TYPE_COLOR, default = Color(1.3, 3.0, 0.5, 0.0) },
	])
