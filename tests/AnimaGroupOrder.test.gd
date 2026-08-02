extends "res://addons/gut/test.gd"

func test_default_kind_is_forward_and_default_origin_is_first():
	var order := AnimaGroupOrder.new()
	assert_eq(order.kind, AnimaGroupOrder.Kind.FORWARD)
	assert_eq(order.origin, AnimaGroupOrder.Origin.FIRST)

func test_group_order_keeps_its_configuration_after_save_and_load():
	var order := AnimaGroupOrder.new()
	order.kind = AnimaGroupOrder.Kind.GRID
	order.origin = AnimaGroupOrder.Origin.INDEX
	order.origin_index = 3
	order.origin_point = Vector2(1.0, 2.0)
	order.seed = 42
	order.grid_columns = 4

	var save_path := "user://anima_group_order_round_trip.tres"
	assert_eq(ResourceSaver.save(order, save_path), OK)
	var restored := load(save_path) as AnimaGroupOrder

	assert_eq(restored.kind, AnimaGroupOrder.Kind.GRID)
	assert_eq(restored.origin, AnimaGroupOrder.Origin.INDEX)
	assert_eq(restored.origin_index, 3)
	assert_eq(restored.origin_point, Vector2(1.0, 2.0))
	assert_eq(restored.seed, 42)
	assert_eq(restored.grid_columns, 4)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
