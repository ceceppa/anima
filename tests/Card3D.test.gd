extends "res://addons/gut/test.gd"

func _make_card_3d() -> Card3D:
	var card: Card3D = preload("res://examples/playground/shared/components/card_3d.tscn").instantiate()
	add_child_autofree(card)
	return card

func test_instantiates_and_uses_the_icosahedron_model():
	var card := _make_card_3d()

	var mesh_instance := card.get_node("%MeshInstance") as MeshInstance3D
	assert_not_null(mesh_instance, "Card3D should hold a MeshInstance3D")
	assert_eq(mesh_instance.mesh, preload("res://examples/playground/models/card.obj"))

func test_set_progress_produces_different_shader_output_across_t():
	var card := _make_card_3d()
	var mesh_instance := card.get_node("%MeshInstance") as MeshInstance3D
	var material := mesh_instance.material_override as ShaderMaterial

	card.set_progress(0.0)
	var rest_progress: float = material.get_shader_parameter("progress")
	var rest_scale := card.scale

	card.set_progress(1.0)
	var complete_progress: float = material.get_shader_parameter("progress")

	card.set_progress(0.5)
	var midpoint_scale := card.scale

	assert_ne(rest_progress, complete_progress, "the shader's progress parameter should change with set_progress")
	assert_ne(rest_scale, midpoint_scale, "the scale pulse should differ between rest and its midpoint peak")

func test_set_progress_clamps_out_of_range_values():
	var card := _make_card_3d()

	card.set_progress(-1.0)
	assert_eq(card.progress, 0.0)

	card.set_progress(2.0)
	assert_eq(card.progress, 1.0)
