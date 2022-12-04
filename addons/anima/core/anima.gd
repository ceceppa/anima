@tool
extends Node

var _animations_list := []
var _custom_animations := {}

static func begin(node: Node, name: String = '_anima_', single_shot := false) -> AnimaNode:
	var node_name_suffix = str(randf()) if single_shot and name == "_anima_" else ""
	var node_name = 'AnimaNode_' + name + node_name_suffix
	var anima_node: AnimaNode

	for child in node.get_children():
		var child_name: String = String(child.name)

		if child_name.find(node_name) >= 0 and is_instance_valid(child):
			anima_node = child
			anima_node.clear()
			anima_node.stop()

			return anima_node

	anima_node = load('res://addons/anima/core/anima_node.gd').new()

	anima_node.name = node_name
	anima_node.init_node(node)

	anima_node.set_single_shot(single_shot)

	return anima_node

static func begin_single_shot(node: Node, name: String = "_anima_") -> AnimaNode:
	return begin(node, name, true)

static func Node(node: Node) -> AnimaDeclarationNode:
	return AnimaDeclarationNode.new(node)

static func Nodes(nodes, items_delay: float) -> AnimaDeclarationNodes:
	return AnimaDeclarationNodes.new(nodes, items_delay)

static func Group(group: Node, items_delay: float, animation_type: int = ANIMA.GROUP.FROM_TOP, point := 0) -> AnimaDeclarationGroup:
	var c := AnimaDeclarationGroup.new()

	return c._init_me(group, items_delay, animation_type, point)

static func Grid(grid: Node, grid_size: Vector2, items_delay: float, animation_type: int = ANIMA.GROUP.FROM_TOP, point := Vector2.ZERO) -> AnimaDeclarationGrid:
	var c := AnimaDeclarationGrid.new()

	return c._init_me(grid, grid_size, items_delay, animation_type, point)

