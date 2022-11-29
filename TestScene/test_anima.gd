extends "res://addons/gut/test.gd"

#
# Creates a AnimaNode and appends it as child of self
#
func test_create_child_anima_node() -> void:
	var anima: AnimaNode = autofree(Anima.begin(self))
	var node: Node = get_node("AnimaNode_anima")

	assert_not_null(anima, "anima is null")
	assert_not_null(node, "AnimaNode_anima not found")

#
# Creates a AnimaNode and with a custom name
#
func test_create_anima_node_with_custom_name() -> void:
	var suffix := "custom_suffix"
	var anima: AnimaNode = autofree(Anima.begin(self, suffix))
	var node: Node = get_node("AnimaNode_" + suffix)

	assert_not_null(anima, "anima is null")
	assert_not_null(node, "AnimaNode_" + suffix + " not found")

#
# Keeps only one instance of AnimaNode
#
func test_remove_other_anima_nodes() -> void:
	var anima0: AnimaNode = autofree(Anima.begin(self))
	var anima1: AnimaNode = autofree(Anima.begin(self))
	var anima2: AnimaNode = autofree(Anima.begin(self))

	assert_freed(anima0, "AnimaNode_anima")
	assert_freed(anima1, "AnimaNode_anima")
	assert_not_null(anima2)

func test_set_single_shot() -> void:
	var anima0: AnimaNode = autofree(Anima.begin(self))
	assert_false(anima0.is_single_shot())

	var anima1: AnimaNode = autofree(Anima.begin(self, "", true))
	assert_true(anima1.is_single_shot())

	var anima2: AnimaNode = autofree(Anima.begin_single_shot(self))
	assert_true(anima2.is_single_shot())
