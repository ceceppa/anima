@tool
extends VBoxContainer

signal node_dragged(node_path)

var _is_dragging := false
var _old_is_dragging := false

func _input(event):
	if _old_is_dragging != _is_dragging:
		_highlight_me()

	_old_is_dragging = _is_dragging

func can_drop_data(position, data):
	if data.type == 'nodes':
		_is_dragging = true

		return true

	_is_dragging = false

	return false

func drop_data(position, data):
	# TODO: Add support for multiple nodes
	var node: NodePath = data.nodes[0]

	emit_signal("node_dragged", str(node))

func _on_AnimationsContainer_mouse_exited():
	_is_dragging = false

func _highlight_me() -> void:
	Anima.begin_single_shot(self) \
		super.with(
			Anima.Node($Control/ColorRect).anima_property("color", Color('00ffffff'), 0.15).anima_from(Color('0affffff'))
		) \
		super.play_as_backwards_when(_is_dragging)

func _on_AnimationsContainer_item_rect_changed():
	$Control/ColorRect.size = size
