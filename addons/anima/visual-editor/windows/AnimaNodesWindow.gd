@tool
extends "./AnimaBaseWindow.gd"

signal node_selected(node, path)

@onready var _anima_nodes_list: VBoxContainer = find_child('AnimaNodesList')

func _ready():
	super._ready()

func populate_nodes_list(root_node: Node) -> void:
	_anima_nodes_list.populate(root_node)

#
#func show() -> void:
#	var anima: AnimaNode = Anima.begin(self)
#
#	anima.then(
#		Anima.Node(self) \
#			super.anima_scale(Vector2.ONE, 0.3) \
#			super.anima_from(Vector2.ZERO) \
#			super.anima_easing(ANIMA.EASING.EASE_IN_OUT_BACK)
#	)
#	anima.with(
#		Anima.Node(self) \
#			super.anima_fade_in() \
#			super.anima_initial_value(0)
#	)
#
#	super.show()
#
#	_anima_nodes_list.populate()
#
#	anima.play()

func _on_AnimaNodesList_node_selected(node: Node, path: String):
	emit_signal("node_selected", node, path)

func _on_AnimaNodesList_close():
	hide()
