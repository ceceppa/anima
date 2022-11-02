extends TextureRect

export (Font) var _font

func _draw():
	draw_circle(Vector2(100, 100), 100, Color.red)
	draw_string(_font, Vector2(100, 100), "AnimaLabel")
