class_name AnimaAwaitableAddChild
extends Reference

static func add_child(parent: Node, node: Node) -> AwaitableAddChild:
	return AwaitableAddChild.new(parent, node)

class AwaitableAddChild:
	signal finished(result)
	
	func _init(parent: Node, node: Node) -> void:
		print("adding")
		call_deferred("add_child", parent, node)
	
	func _callAndSignal(parent: Node, node: Node) -> void:
		var result = parent.add_child(node)

		print_debug("done")
		emit_signal("finished", result)
