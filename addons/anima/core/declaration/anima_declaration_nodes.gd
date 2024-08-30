class_name AnimaDeclarationNodes
extends AnimaDeclarationNode

func _init(nodes, items_delay: float):
	_data.items_delay = items_delay

	var the_nodes: Array

	if nodes is Node:
		for child in nodes.get_children():
			if _can_add_node(child):
				the_nodes.push_back(child)
	else:
		#
		# Flattens the nodes
		#
		for node in nodes:
			if node is Array:
				for child in node:
					if _can_add_node(child):
						the_nodes.push_back(child)
			else:
				if _can_add_node(node):
					the_nodes.push_back(node)

	_data.nodes = the_nodes

func _can_add_node(child) -> bool:
	return "visible" in child and child.visible
