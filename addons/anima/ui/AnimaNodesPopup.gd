tool
extends PopupPanel

signal node_selected(node, path)

onready var _anima_nodes_list: VBoxContainer = find_node('AnimaNodesList')

func show() -> void:
	var anima: AnimaNode = Anima.begin(self)

	anima.then(
		Anima.Node(self) \
			.anima_property("scale") \
			.anima_from(Vector2.ZERO) \
			.anima_to(Vector2.ONE) \
			.anima_duration(0.3) \
			.anima_easing(Anima.EASING.EASE_IN_OUT_BACK)
	)
	anima.also({ 
		property = "opacity",
		from = 0,
		to = 1,
		initial_value = 0,
	})

	.show()

	_anima_nodes_list.populate()

	anima.play()

func _on_AnimaNodesList_node_selected(node: Node, path: String):
	emit_signal("node_selected", node, path)
