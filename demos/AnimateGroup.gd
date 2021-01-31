extends Control

var _tile_size: Vector2

func _ready():
	var size = self.rect_size
	_tile_size = $tile.texture.get_size()

	var max_y = ceil(size.y / _tile_size.y) + 1
	var max_x = ceil(size.x / _tile_size.x) + 1

	var start_x = size.x / 2 - (_tile_size.x * max_x) / 2
	var start_y = size.y / 2 - (_tile_size.y * max_y) / 2
	for y in range(0, max_y):
		for x in range(0, max_x):
			var new_tile = $tile.duplicate()

			new_tile.position.x = start_x + x * _tile_size.x
			new_tile.position.y = start_y + y * _tile_size.y

			$Grid.add_child(new_tile)

	$tile.free()

	Anima.register_animation(self, 'gridAnimation')

	var anima = Anima.group($Grid)
	anima.set_animation('gridAnimation')
	anima.set_start_delay(0.5)
	anima.set_items_delay(0.05)
	anima.set_item_duration(1.0)
	anima.set_animation_type(Anima.Grid.SEQUENCE_TOP_LEFT)
	anima.end()

	anima.play()

	yield(anima, "animation_completed")
	print('yay, all done :)')

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var size = self.rect_size
	var center_x = (size.x / 2) - (_tile_size.x / 2)

	var position_frames = [
		{ to = Vector2(center_x, -100) },
	]

	var zooom_frames = [
		{ from = Vector2(1, 1), to = Vector2(0, 0) },
	]

	var opacity = [
		{ from = 1, to = 0 }
	]

#	anima_tween.add_frames(data, "opacity", opacity)
	anima_tween.add_frames(data, "scale", zooom_frames)
	anima_tween.add_frames(data, "position", position_frames)

