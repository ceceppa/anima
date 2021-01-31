class_name AnimaNode
extends Node

signal animation_completed

var _anima_tween := AnimaTween.new()

var _total_animation := 0.0
var _last_animation_duration := 0.0

var _timer := Timer.new()
var _loop_times := 0
var _tweens_left := 0

var _ignore

func _ready():
	if _timer.get_parent() != self:
		_init_node(self)

func _exit_tree():
	_timer.stop()
	_anima_tween.stop_all()

	_timer.queue_free()
	_anima_tween.queue_free()

func _init_node(node: Node):
	_timer.one_shot = true
	_timer.autostart = false
	_timer.connect("timeout", self, '_on_timer_timeout')

	_anima_tween.connect("tween_completed", self, '_on_tween_completed')
	_anima_tween.connect("tween_all_completed", self, '_on_all_tween_completed')

	add_child(_timer)
	add_child(_anima_tween)

	if node != self:
		node.add_child(self)

func then(data: Dictionary):
	data._wait_time = _total_animation

	_last_animation_duration = _setup_animation(data)
	_total_animation += _last_animation_duration

func with(data: Dictionary) -> void:
	var start_time := 0.0
	var delay = data.delay if data.has('delay') else 0.0

	start_time = max(0, _total_animation - _last_animation_duration)

	if not data.has('duration'):
		if _last_animation_duration > 0:
			data.duration = _last_animation_duration
		else:
			data.duration = 0.7

	data._wait_time = start_time + delay

	var duration := _setup_animation(data)

func set_visibility_strategy(strategy: int) -> void:
	_anima_tween.set_visibility_strategy(strategy)

func clear() -> void:
	stop()

	_anima_tween.clear_animations()

	_total_animation = 0.0
	_last_animation_duration = 0.0

func play() -> void:
	_loop_times = 1
	_timer.wait_time = 0.00001
	_timer.one_shot = true

	_timer.start()

func stop() -> void:
	_timer.stop()
	_anima_tween.stop_all()

#func loop(times: int = -1) -> void:
#	_loop_times = times
#	_timer.wait_time = 0.00001
#
#	_do_play()

func play_with_delay(delay: float) -> void:
	_loop_times = 1

	_timer.set_wait_time(delay)
	_timer.start()

func get_length() -> float:
	return _total_animation

func _do_play() -> void:
#		stop()

	_tweens_left = _anima_tween.get_animations_count()
	_anima_tween.play()

func _setup_animation(data: Dictionary) -> float:
	var node = data.node
	var duration = data.duration if data.has('duration') else 0.7
	var delay = data.delay if data.has('delay') else 0.0

	if data.has('pivot'):
		AnimaNodesProperties.set_pivot(node, data.pivot)

	data._wait_time = max(0.0, data._wait_time + delay)

	if data.has('property') and not data.has('animation'):
		data._is_first_frame = true

	if data.has('animation'):
		var script = Anima.get_animation_script(data.animation)

		if not script:
			printerr('animation not found: %s' % data.animation)

			return duration

		var real_duration = script.generate_animation(_anima_tween, data)
		if real_duration is float:
			duration = real_duration
	else:
		_anima_tween.add_animation_data(data)

	return duration

func _on_tween_completed(_ignore, _ignore2) -> void:
	_tweens_left -= 1

	if _tweens_left == 0: 
		_loop_times -= 1
		
		if _loop_times > 0:
			_timer.start()

func _on_timer_timeout() -> void:
	_do_play()

	_loop_times -= 1

	if _loop_times > 0:
		_timer.start()

func _on_all_tween_completed() -> void:
	emit_signal("animation_completed")
