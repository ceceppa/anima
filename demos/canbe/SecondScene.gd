extends CenterContainer

var _line_width: int = 150
onready var _half_anima_label_height: float = ($Anima.rect_size.y / 2)

func _ready():
	Anima.register_animation(self, 'draw_line_1')
	Anima.register_animation(self, 'rotate_line_1')
	Anima.register_animation(self, 'move_line_1')
	Anima.register_animation(self, 'move_line_1_again')

	Anima.register_animation(self, 'draw_line_2')
	Anima.register_animation(self, 'rotate_line_2')
	Anima.register_animation(self, 'move_line_2')
	Anima.register_animation(self, 'move_line_2_again')

	Anima.register_animation(self, 'animate_anima')

	if get_parent() is Viewport:
		get_anima().play_with_delay(0.5)

func get_anima() -> AnimaNode:
	var anima := Anima.begin(self)
	anima.then({ node = $AnimaLine, animation = 'draw_line_1', duration = 0.5 })
	anima.with({ node = $AnimaLine2, animation = 'draw_line_2', duration = 0.5 })

	anima.then({ node = $AnimaLine, animation = 'rotate_line_1', duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })
	anima.with({ node = $AnimaLine2, animation = 'rotate_line_2', duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })

	anima.then({ node = $AnimaLine, animation = 'move_line_1', duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })
	anima.with({ node = $AnimaLine2, animation = 'move_line_2', duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })

	anima.then({ node = $AnimaLine, animation = 'move_line_1_again', duration = 0.3, delay = - 0.1, easing = Anima.EASING.EASE_OUT_CUBIC })
	anima.with({ node = $AnimaLine2, animation = 'move_line_2_again', duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })

	anima.with({ group = $Anima, animation = 'animate_anima', duration = 0.5, easing_points = [0.5,1,0.85,1.78], visibility_strategy = Anima.VISIBILITY.TRANSPARENT_ONLY })

	anima.then({ node = $AnimaLine, property = '_x1', to = 100, relative = true, duration = 0.3, delay = -0.1, easing = Anima.EASING.EASE_OUT_CUBIC })
	anima.with({ node = $AnimaLine, property = '_x2', to = -100, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })

	anima.with({ node = $AnimaLine2, property = '_x1', to = -100, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })
	anima.with({ node = $AnimaLine2, property = '_x2', to = 100, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_CUBIC })

	anima.wait(3.0)

	anima.then({ group = $Anima, property = 'opacity', to = 0, duration = 0.2, items_delay = 0.05, animation_type = Anima.GRID.RANDOM })
	anima.with({ node = $Anima, property = '_letter_spacing', to = 20, duration = 0.5, easing = Anima.EASING.EASE_IN_CUBIC })

	anima.with({ node = $AnimaLine, property = '_x1', to = 0, duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })
	anima.with({ node = $AnimaLine, property = '_x2', to = 0, duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })
	anima.with({ node = $AnimaLine, property = 'opacity', to = 0, duration = 0.1, delay = 0.2 })

	anima.with({ node = $AnimaLine2, property = '_x1', to = 0, duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })
	anima.with({ node = $AnimaLine2, property = '_x2', to = 0, duration = 0.3, easing = Anima.EASING.EASE_IN_CUBIC })
	anima.with({ node = $AnimaLine2, property = 'opacity', to = 0, duration = 0.1, delay = 0.2 })

	return anima

func draw_line_1(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707

	var start: int = - _line_width + middle_x
	data.node._x1 = start
	data.node._y1 = start
	data.node._x2 = start
	data.node._y2 = start

	var final_x: float = _line_width / sin45 + middle_x

	anima_tween.add_frames(data, '_x1', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = start, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	anima_tween.add_frames(data, '_y1', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = start, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	
	anima_tween.add_frames(data, '_x2', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = _line_width + middle_x, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	anima_tween.add_frames(data, '_y2', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = _line_width + middle_x, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)

func rotate_line_1(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707

	var final_x: float = _line_width / sin45 + middle_x

	anima_tween.add_frames(data, '_x1', [ { to = -final_x } ] )
	anima_tween.add_frames(data, '_y1', [ { to = middle_x } ] )
	anima_tween.add_frames(data, '_x2', [ { to = final_x } ] )
	anima_tween.add_frames(data, '_y2', [ { to = middle_x } ] )

func move_line_1(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707

	var final_x: float = _line_width / sin45 + middle_x
	var final_y: int = middle_x - _half_anima_label_height

	anima_tween.add_frames(data, '_x1', [ { to = -final_x } ] )
	anima_tween.add_frames(data, '_y1', [ { to = final_y}, ] )
	anima_tween.add_frames(data, '_x2', [ { to = final_x } ] )
	anima_tween.add_frames(data, '_y2', [ { to = final_y}, ] )

func move_line_1_again(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var width = _line_width + 30
	var sin45 := 0.707

	var final_x: float = width / sin45 + middle_x
	var final_y: int = middle_x - _half_anima_label_height - 20

	anima_tween.add_frames(data, '_x1', [ { to = -final_x } ] )
	anima_tween.add_frames(data, '_y1', [ { to = final_y}, ] )
	anima_tween.add_frames(data, '_x2', [ { to = final_x } ] )
	anima_tween.add_frames(data, '_y2', [ { to = final_y}, ] )

func draw_line_2(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707

	var start: int =  - _line_width + middle_x
	data.node._x1 = -start
	data.node._y1 = start
	data.node._x2 = -start
	data.node._y2 = start

	var final_x: float = _line_width / sin45 + middle_x

	anima_tween.add_frames(data, '_x1', 
		[
			{ percentage = 0, from = -start },
			{ percentage = 100, to = -start, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	anima_tween.add_frames(data, '_y1', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = start, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	
	anima_tween.add_frames(data, '_x2',
		[
			{ percentage = 0, from = - start },
			{ percentage = 100, to = - _line_width + middle_x, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)
	anima_tween.add_frames(data, '_y2', 
		[
			{ percentage = 0, from = start },
			{ percentage = 100, to = _line_width + middle_x, easing = Anima.EASING.EASE_OUT_QUAD },
		]
	)

func rotate_line_2(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707

	var start: int =  - _line_width + middle_x
	var final_x: float = _line_width / sin45 + middle_x

	anima_tween.add_frames(data, '_x1', [{ to = final_x }])
	anima_tween.add_frames(data, '_y1', [{ to = middle_x }])
	anima_tween.add_frames(data, '_x2', [{ to = - final_x }])
	anima_tween.add_frames(data, '_y2', [{ to = middle_x }])

func move_line_2(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var sin45 := 0.707
	var final_x: float = _line_width / sin45 + middle_x
	var final_y: float = middle_x + _half_anima_label_height

	anima_tween.add_frames(data, '_x1', [{ to = final_x }])
	anima_tween.add_frames(data, '_y1', [{ to = final_y }])
	anima_tween.add_frames(data, '_x2', [{ to = -final_x }])
	anima_tween.add_frames(data, '_y2', [{ to = final_y }])

func move_line_2_again(anima_tween: AnimaTween, data: Dictionary) -> void:
	var middle_x: int = (data.node.rect_size.x / 2)
	var width = _line_width + 30
	var sin45 := 0.707
	var final_x: float = width / sin45 + middle_x
	var final_y: float = middle_x + _half_anima_label_height + 20

	anima_tween.add_frames(data, '_x1', [{ to = final_x }])
	anima_tween.add_frames(data, '_y1', [{ to = final_y }])
	anima_tween.add_frames(data, '_x2', [{ to = -final_x }])
	anima_tween.add_frames(data, '_y2', [{ to = final_y }])

func animate_anima(anima_tween: AnimaTween, data: Dictionary) -> void:
	anima_tween.add_frames(data, '_text_scale:y', [ { from = 0.0, to = 1.0 }])
	anima_tween.add_frames(data, 'opacity', [ { from = 1, to = 1 }])
