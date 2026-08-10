extends Control

func _ready() -> void:
	$Control.modulate.a = 0.0
	$Control2.modulate.a = 0.0
	$OverlayBg.color.a = 0.0

	_reset_grid()

func _reset_grid():
	for index in %InventoryGrid._tiles.size():
		%InventoryGrid._tiles[index].modulate.a = 0.0
		%InventoryGrid._icon_nodes[index].modulate.a = 1.0

func _anima_grid() -> AnimaGridMotionFactory:
	return Anima.grid(%InventoryGrid.get_node("Tiles"), Vector2i(%InventoryGrid._columns, %InventoryGrid._rows))

func _wait_for_next():
	await get_tree().create_timer(1).timeout

func play() -> AnimaPlayback:
	%Label.text = 'Anima.grid(Tiles, Vector2i(9, 5)).diamond().with_start_point(Vector2.ZERO).play()'
	await _anima_grid().diamond().with_start_point(Vector2.ZERO).play().finished
	await _wait_for_next()
	_reset_grid()

	%Label.text = 'Anima.grid(Tiles, Vector2i(9, 5)).diagonal().play()'
	await _anima_grid().diagonal().play().finished
	await _wait_for_next()
	_reset_grid()

	%Label.text = 'Anima.grid(Tiles, Vector2i(9, 5)).spiral_in().play()'

	var overlay_fade := Anima.on(%OverlayBg).property(NodePath("color:a"), 0.85, 1.0).with_delay(0.5)

	Anima.play(overlay_fade, %OverlayBg)
	
	var b = Anima.on($Control2).keyframes({
		"from": {
			"scale": Vector2(0.8, 0.8),
			"opacity": 0.0,
		},
		"to": {
			"scale": Vector2.ONE,
			"opacity": 1.0
		}
	}).with_pivot(AnimaPropertyMotion.Pivot.CENTER).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
	b.delay = 1.0
	
	_anima_grid().spiral_in().play()
	
	var p = Anima.on(%Label).property(NodePath("modulate:a"), 0.0, 0.3)
	Anima.play(p, %Label)
	
	await Anima.play(b, $Control2).finished

	var c = Anima.on($Control2).keyframes({
		"from": {
			"scale": Vector2.ONE,
			"opacity": 1.0,
		},
		"to": {
			"scale": Vector2(2.0, 2.0),
			"opacity": 0.0
		}
	}).with_pivot(AnimaPropertyMotion.Pivot.CENTER).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
	c.delay = 1.0

	var d = Anima.on(%Control).keyframes({
		"from": {
			"scale": Vector2(0.8, 0.8),
			"opacity": 0.0,
		},
		"to": {
			"scale": Vector2.ONE,
			"opacity": 1.0
		}
	}).with_pivot(AnimaPropertyMotion.Pivot.CENTER).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
	d.delay = 1.0

	Anima.play(c, $Control2)

	return Anima.play(d, %Control)
