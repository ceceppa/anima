tool
extends "./AnimaBaseWindow.gd"

signal node_selected(node, path)

onready var _anima_nodes_list: VBoxContainer = find_node('AnimaNodesList')

func _ready():
	._ready()

func populate_nodes_list(root_node: Node) -> void:
	_anima_nodes_list.populate(root_node)

func _on_AnimaNodesList_node_selected(node: Node, path: String):
	emit_signal("node_selected", node, path)

func _on_AnimaNodesList_close():
	hide()
