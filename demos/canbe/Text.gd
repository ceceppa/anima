extends VBoxContainer

func _ready():
	Anima.register_animation(self, 'fade_letters_in')
	Anima.register_animation(self, 'animate_with_in')
	Anima.register_animation(self, 'move_y')
	Anima.register_animation(self, 'replace_letter_color')
	Anima.register_animation(self, 'godot_text')
	Anima.register_animation(self, 'move_out')

	if get_parent() is Viewport:
		get_anima().play_with_delay(0.5)

func get_anima() -> AnimaNode:
	var anima: AnimaNode = Anima.begin(self)
	var letter_e = $Can.get_child(5)

	anima.then({ 
		group = $Can,
		animation = 'fade_letters_in',
		duration = 0.5,
		items_delay = 0.01,
		easing = Anima.EASING.EASE_OUT_BACK,
		on_started = [funcref(self, '_change_e_color'), letter_e] 
	})
	anima.with({ node = letter_e, animation = 'replace_letter_color', duration = 0.3, delay = 0.5, easing = Anima.EASING.EASE_OUT_QUAD })
	anima.then({ node = $With, animation = 'move_y', duration = 0.5, delay = -0.1, easing = Anima.EASING.EASE_OUT_QUAD })
	anima.then({ group = $Godot, animation = 'godot_text', duration = 0.3, items_delay = 0.05, easing = Anima.EASING.EASE_OUT_QUAD })
	anima.wait(2)

	anima.then({ group = $Can, animation = 'move_out', duration = 0.5, items_delay = 0.0 })
	anima.with({ node = $With, animation = 'move_out', duration = 0.5, delay = 0.05 })
	anima.with({ group = $Godot, animation = 'move_out', duration = 0.5, items_delay = 0.0, delay = 0.05 })

	anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	return anima

func _change_e_color(node: AnimaLabel) -> void:
	node._font_color = Color.red

func fade_letters_in(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames := [
		{ from = 50, to = 0 }
	]
	var opacity := [
		{ from = 0, to = 1 }
	]

	anima_tween.add_frames(data, '_text_offset:y', frames)
	anima_tween.add_frames(data, 'opacity', opacity)

func move_y(anima_tween: AnimaTween, data: Dictionary) -> void:
	var y = data.node.rect_size.y
	var frames := [
		{ from = y, to = 0 }
	]

	anima_tween.add_frames(data, '_text_offset:y', frames)

func replace_letter_color(anima_tween: AnimaTween, data: Dictionary) -> void:
	var y = $Godot.get_child(0).rect_size.y

	var modulate := [
		{ percentage = 0, from = Color.red },
		{ percentage = 50, to = Color.red },
		{ percentage = 51, from = Color.black },
		{ percentage = 100, to = Color.black },
	]

	var frames := [
		{ percentage = 0, from = 0 },
		{ percentage = 50, to = -y },
		{ percentage = 51, from = y },
		{ percentage = 100, to = 0, easing = Anima.EASING.EASE_OUT_QUAD },
	]

	anima_tween.add_frames(data, '_font_color', modulate)
	anima_tween.add_frames(data, '_text_offset:y', frames)

func godot_text(anima_tween: AnimaTween, data: Dictionary) -> void:
	var node: AnimaLabel = data.node
	var size = node.rect_size
	
	node._container_scale.x = 0.1

	anima_tween.add_frames(data, '_text_offset:y', [{ from = size.y, to = 0 }])
	anima_tween.add_frames(data, '_text_scale:x', [{ from = 0, to = 1 }])
	anima_tween.add_frames(data, '_container_scale:x', [{ from = 0, to = 1 }])

func move_out(anima_tween: AnimaTween, data: Dictionary) -> void:
	var y = data.node.rect_size.y

	var frames := [
		{ from = 0, to = y, easing = Anima.EASING.EASE_OUT_QUAD },
	]

	anima_tween.add_frames(data, '_text_offset:y', frames)
