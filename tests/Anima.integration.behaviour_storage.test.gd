extends "res://addons/gut/test.gd"

func test_attach_behaviour_does_not_change_the_nodes_class():
	var node := Node2D.new()
	add_child_autofree(node)

	Anima.attach_behaviour(node, AnimaBehaviour.new())

	assert_eq(node.get_class(), "Node2D")

func test_get_behaviour_returns_the_exact_attached_instance():
	var node := Node2D.new()
	add_child_autofree(node)

	var behaviour := AnimaBehaviour.new()
	behaviour.motion_id = "test-behaviour"
	Anima.attach_behaviour(node, behaviour)

	assert_eq(Anima.get_behaviour(node), behaviour)

func test_get_behaviour_returns_null_when_nothing_attached():
	var node := Node2D.new()
	add_child_autofree(node)

	assert_null(Anima.get_behaviour(node))

func test_attach_behaviour_adds_the_node_to_the_discovery_group():
	var node := Node2D.new()
	add_child_autofree(node)

	Anima.attach_behaviour(node, AnimaBehaviour.new())

	assert_true(node.is_in_group(Anima.BEHAVIOUR_GROUP))

func test_attached_behaviour_survives_a_pack_and_instantiate_round_trip():
	var node := Node2D.new()
	node.name = "BehaviourNode"

	var behaviour := AnimaBehaviour.new()
	behaviour.motion_id = "packed-behaviour"
	Anima.attach_behaviour(node, behaviour)

	var packed := PackedScene.new()
	var pack_result := packed.pack(node)
	assert_eq(pack_result, OK)
	node.free()

	var instance: Node2D = packed.instantiate()
	add_child_autofree(instance)

	var restored := Anima.get_behaviour(instance)
	assert_not_null(restored, "the behaviour should survive a pack/instantiate round trip")
	assert_eq(restored.motion_id, "packed-behaviour")
