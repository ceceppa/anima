tool
extends Control
class_name AnimaShape

# TODO: Hover, Click animation
var _anima: AnimaNode

func _ready():
	_anima = Anima.begin(self)

func animate(anima_data: Dictionary, auto_play := true) -> AnimaNode:
	var anima: AnimaNode = Anima.begin(self)

	anima.then(anima_data)

	if auto_play:
		anima.play()

	return anima

func get_anima_node() -> AnimaNode:
	return _anima
