tool
extends PopupPanel

signal node_selected(node, path)

onready var _anima_nodes_list: VBoxContainer = find_node('AnimaNodesList')

func show() -> void:
	var anima: AnimaNode = Anima.begin(self)
	anima.then({ property = "scale", from = Vector2.ZERO, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK })
	anima.also({ property = "opacity", from = 0, to = 1 })
	anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	.show()

	_anima_nodes_list.populate()

	anima.play()

func _on_AnimaNodesList_node_selected(node: Node, path: String):
	emit_signal("node_selected", node, path)
