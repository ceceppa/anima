extends Panel

var _bg_rect: Rect2 = Rect2(0, 0, 0, 0) setget _set_bg_rect
var _bg_rect_size: Vector2 = Vector2(0, 0) setget _set_bg_rect_size
var _screen_multiplier := Vector2(1, 1)

onready var _original_half_width: Vector2 = rect_size / 2
onready var _half_width: Vector2 = rect_size / 2

func _ready():
	var player: AnimaPlayer = Anima.player(self)

	player.then(self._get_anima())
	player.then($VBoxContainer/Header._get_anima())

	player.play_with_delay(0.3)

func _draw():
	var size: Vector2 = _bg_rect_size * _screen_multiplier

	_bg_rect.position = _half_width - (size / 2)
	_bg_rect.size = size

	draw_rect(_bg_rect, Color('#f5f5fd'), true, 0.0, true)
	
	var r = _bg_rect
	var s = size * 1.1
	r.position =  _half_width - (s / 2)
	r.size = s
	draw_rect(r, Color('#f5f5fd'), false, 2.0, true)

func _set_bg_rect(new_rect: Rect2) -> void:
	_bg_rect = new_rect

	update()

func _set_bg_rect_size(size: Vector2) -> void:
	_bg_rect_size = size

	update()

func _get_anima() -> AnimaNode:
	var anima: AnimaNode = Anima.begin(self)

	anima.then({ property = "_bg_rect_size", from = Vector2(0, 0), to = Vector2(300, 2), duration = 0.2})
	anima.then({ property = "_bg_rect_size", to = Vector2(300, 100), duration = 0.3})

	anima.then({ node = $AnimaLabel, property = 'opacity', duration = 0.3, to = 1, visibility_strategy = Anima.VISIBILITY.TRANSPARENT_ONLY })
	anima.with({ node = $AnimaLabel, animation = 'typewrite', duration = 0.3 })

	anima.wait(0.7)

	anima.then({ node = $AnimaLabel, property = 'opacity', duration = 0.3, to = 0 })
	anima.then({ property = "_bg_rect_size", to = Vector2(rect_size.x, 20), duration = 0.2})
	anima.then({ property = "_bg_rect_size", to = rect_size, duration = 0.3})

	return anima

func _on_DemoSelector_item_rect_changed():
	_half_width = rect_size / 2

	if _original_half_width == null:
		return

	_screen_multiplier = _half_width / _original_half_width

	update()
