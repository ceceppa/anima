extends Panel

export (Texture) var _image

onready var _image_height = rect_size.y setget _set_image_height
onready var _original_height = _image_height

func _ready():
	_on_CardPanel_mouse_exited()

func _get_anima_node():
	var anima = Anima.begin(self)

	Anima.register_animation(self, 'card_in')
	Anima.register_animation(self, 'show_details')

	anima.then({ node = $CardPanel, animation = 'card_in', duration = 0.3 })
	anima.then({ node = $CardPanel/Info, animation = 'show_details', duration = 0.3, delay = 0.1 })
	anima.with({ node = $CardPanel/Info/Title, animation = 'typewrite', duration = 0.3 })
	anima.with({ node = $CardPanel/Info/Subtitle, animation = 'typewrite', duration = 0.3, delay = 0.15 })

	anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames := {}

	if data.animation == 'card_in':
		frames = _card_in_animation()
	else:
		frames = _show_details_animation()

	for key in frames:
		anima_tween.add_frames(data, key, frames[key])

func _card_in_animation() -> Dictionary:
	var scale_frames := [ { from = Vector2(0.7, 0.7), to = Vector2(1, 1), easing = Anima.EASING.EASE_OUT_BACK, pivot = Anima.PIVOT.CENTER }]
	var opacity_frames := [ { from = 0, to = 1 }]

	return {
		scale = scale_frames,
		opacity = opacity_frames
	}

func _show_details_animation() -> Dictionary:
	var y_frames := [ { from = 30, to = -30, relative = true, easing = Anima.EASING.EASE_OUT_BACK }]
	var opacity_frames := [ { from = 0, to = 1 }]

	return {
		y = y_frames,
		opacity = opacity_frames
	}

func _draw():
	var image: StreamTexture = _image

	var src_size: Vector2 = image.get_size()
	var src_ratio: float = src_size.x / src_size.y

	var dest_size := Vector2(rect_size.x, rect_size.y)
	var dest_ratio: float = dest_size.x / dest_size.y

	var src_width = src_size.x
	var src_height: float = src_width / dest_ratio
	var src_top: float = (src_size.y - src_height) / 2

	var src_rect :=  Rect2(0, src_top, src_width, src_height)
	var dest_rect := Rect2(0, 0, dest_size.x, dest_size.y)

	draw_texture_rect_region(_image, dest_rect, src_rect)

func _set_image_height(height: float) -> void:
	_image_height = height

	update()

func _animate_height_change(anchor_top: float, opacity: int) -> void:
	var anima := Anima.begin(self)

	anima.then({ node = $Title, property = "anchor_top", to = anchor_top, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK })
	anima.with({ node = $Title, property = "anchor_bottom", to = anchor_top + 0.1, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK, delay = 0.1 })

	anima.with({ node = $Subtitle, property = "anchor_top", to = anchor_top + 0.1, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK, delay = 0.1 })
	anima.with({ node = $Subtitle, property = "anchor_bottom", to = anchor_top + 0.2, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK, delay = 0.1 })
	anima.with({ node = $Subtitle, property = "opacity", to = opacity, duration = 0.3, visibility_strategy = Anima.VISIBILITY.TRANSPARENT_ONLY })

	anima.play()

func _on_CardPanel_mouse_entered():
	_animate_height_change(0.8, 1)

func _on_CardPanel_mouse_exited():
	_animate_height_change(0.9, 0)

func _on_CardPanel_item_rect_changed():
	update()
