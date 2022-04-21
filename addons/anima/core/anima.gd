tool
extends Node

enum PIVOT {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

enum VISIBILITY {
	IGNORE,
	HIDDEN_ONLY,
	TRANSPARENT_ONLY,
	HIDDEN_AND_TRANSPARENT
}

enum GRID {
	TOGETHER,
	SEQUENCE_TOP_LEFT,
	SEQUENCE_BOTTOM_RIGHT,
	COLUMNS_ODD,
	COLUMNS_EVEN,
	ROWS_ODD,
	ROWS_EVEN,
	ODD,
	EVEN,
	FROM_CENTER,
	FROM_POINT,
	RANDOM
}

const GROUP := {
	TOGETHER = GRID.TOGETHER,
	FROM_TOP = GRID.SEQUENCE_TOP_LEFT,
	FROM_BOTTOM = GRID.SEQUENCE_BOTTOM_RIGHT,
	FROM_CENTER = GRID.FROM_CENTER,
	ODDS_ONLY = GRID.COLUMNS_ODD,
	EVEN_ONLY = GRID.COLUMNS_EVEN,
	RANDOME = GRID.RANDOM,
	FROM_INDEX = GRID.FROM_POINT
}

enum LOOP_STRATEGY {
	USE_EXISTING_RELATIVE_DATA,
	RECALCULATE_RELATIVE_DATA,
}

enum TYPE {
	NODE,
	GROUP,
	GRID
}

enum VALUES_IN {
	PIXELS,
	PERCENTAGE
}

const Align = {
	LEFT = HALIGN_LEFT,
	CENTER = HALIGN_CENTER,
	RIGHT = HALIGN_RIGHT,
}

const VAlign = {
	TOP = VALIGN_TOP,
	CENTER = VALIGN_CENTER,
	BOTTOM = VALIGN_BOTTOM,
}

enum RELATIVE_TO {
	INITIAL_VALUE,
	PREVIOUS_FRAME,
}

const EASING = AnimaEasing.EASING

const DEFAULT_DURATION := 0.7
const DEFAULT_ITEMS_DELAY := 0.05
const MINIMUM_DURATION := 0.000001

var _animations_list := []
var _custom_animations := {}

static func begin(node: Node, name: String = 'anima', single_shot := false) -> AnimaNode:
	var node_name = 'AnimaNode_' + name
	var anima_node: AnimaNode

	for child in node.get_children():
		if child.name.find(node_name) >= 0 and is_instance_valid(child):
			anima_node = child
			anima_node.clear()
			anima_node.stop()

			return anima_node

	anima_node = load('res://addons/anima/core/anima_node.gd').new()

	anima_node.name = node_name
	anima_node.init_node(node)

	anima_node.set_single_shot(single_shot)

	return anima_node

static func begin_single_shot(node: Node, name: String = "anima") -> AnimaNode:
	return begin(node, name, true)

#
#static func player(node: Node):
#	var player = load('./player.gd').new()
#
#	node.add_child(player)
#
#	return player

static func Node(node: Node) -> AnimaDeclarationNode:
	return AnimaDeclarationNode.new(node)

static func Group(group: Node, items_delay: float, animation_type: int = GROUP.FROM_TOP, point := 0) -> AnimaDeclarationGroup:
	var c := AnimaDeclarationGroup.new()

	return c._init_me(group, items_delay, animation_type, point)

static func Grid(grid: Node, grid_size: Vector2, items_delay: float, animation_type: int = GROUP.FROM_TOP, point := 0) -> AnimaDeclarationGrid:
	var c := AnimaDeclarationGrid.new()

	return c._init_me(grid, grid_size, items_delay, animation_type, point)

