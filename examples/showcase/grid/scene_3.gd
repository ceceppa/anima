extends Control

## [method play] is not auto-called from [method Node._ready] — the parent
## [GridShowcase] orchestrator calls it via [method _run_show], the same
## convention `layer_1.gd` (Scene 1) already documents. Calling it here too
## used to double-trigger this scene's animation (once here, once from
## `_run_show()`), leaving an orphaned, never-cancelled [AnimaPlayback]
## running past this scene's own lifetime whenever it was torn down before
## naturally finishing.
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

func _update_text(formula: String) -> void:
	%Label.text = "Anima.grid(Tiles, Vector2i(8, 5)).%s.play()" % formula

	_reset_grid()

func play() -> void:
	(
		_anima_grid()
			.diamond()
			.with_start_point(Vector2.ZERO)
			.on_started(func(): _update_text('.diamond().with_start_point(Vector2.ZERO)'))
		.then(
			_anima_grid()
			.diagonal()
			.on_started(func(): _update_text('.diagonal()'))
			.with_delay(1)
		)
		.then(
			_anima_grid()
			.spiral_in()
			.on_started(func(): _update_text('.spiral_in()'))
			.with_delay(1)
			.with(
				Anima.on(%OverlayBg)
				.property(NodePath("color:a"), 0.85, 1.0)
				.with_delay(1.0)
			)
		)
		.then(
			Anima.on(%Control2).keyframes({
				"from": {
					"scale": Vector2(0.8, 0.8),
					"opacity": 0.0,
				},
				"to": {
					"scale": Vector2.ONE,
					"opacity": 1.0
				}
			})
			.with_pivot(AnimaPivot.Kind.CENTER)
			.with_ease(AnimaEase.Kind.EASE_OUT_BACK)
			.with_delay(1.0)
		)
		.then(
			Anima.on(%Control2).keyframes({
				"from": {
					"scale": Vector2.ONE,
					"opacity": 1.0,
				},
				"to": {
					"scale": Vector2(2.0, 2.0),
					"opacity": 0.0
				}
			})
			.with_pivot(AnimaPivot.Kind.CENTER)
			.with_ease(AnimaEase.Kind.EASE_OUT_BACK)
			.with_delay(1.0)
		)
		.then(
			Anima.on(%Control).keyframes({
				"from": {
					"scale": Vector2(0.8, 0.8),
					"opacity": 0.0,
				},
				"to": {
					"scale": Vector2.ONE,
					"opacity": 1.0
				}
			})
			.with_pivot(AnimaPivot.Kind.CENTER)
			.with_ease(AnimaEase.Kind.EASE_OUT_BACK)
		)
	).play()
