class_name AnimaNode
extends Node

signal animation_started
signal animation_completed
signal loop_started
signal loop_completed

var _anima_tween := AnimaTween.new()

var _total_animation := 0.0
var _last_animation_duration := 0.0

var _timer := Timer.new()
var _loop_times := 0
var _loop_count := 0
var _should_loop := false
var _loop_strategy = Anima.LOOP.USE_EXISTING_RELATIVE_DATA

var __do_nothing := 0.0

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

	_anima_tween.connect("tween_all_completed", self, '_on_all_tween_completed')

	add_child(_timer)
	add_child(_anima_tween)

	if node != self:
		node.add_child(self)

func then(data: Dictionary):
	data._wait_time = _total_animation

	_last_animation_duration = _setup_animation(data)

	var delay = data.delay if data.has('delay') else 0.0
	_total_animation += _last_animation_duration + delay

func with(data: Dictionary) -> void:
	var start_time := 0.0
	var delay = data.delay if data.has('delay') else 0.0

	start_time = max(0, _total_animation - _last_animation_duration)

	if not data.has('duration'):
		if _last_animation_duration > 0:
			data.duration = _last_animation_duration
		else:
			data.duration = Anima.DEFAULT_DURATION

	data._wait_time = start_time

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

func loop(times: int = -1) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = times == -1

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()

func loop_with_delay(delay: float, times: int = -1) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = true

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()
	
	_timer.wait_time = max(0.00001, delay)

func loop_times_with_delay(times: float, delay: float) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = times == -1

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()
	
	_timer.wait_time = max(0.00001, delay)

func play_with_delay(delay: float) -> void:
	_loop_times = 1

	_timer.set_wait_time(delay)
	_timer.start()

func get_length() -> float:
	return _total_animation

func _do_play() -> void:
	_loop_count += 1

	_anima_tween.reset_all()
	_anima_tween.play()
	
	emit_signal("animation_started")
	emit_signal("loop_started", _loop_count)

func set_loop_strategy(strategy: int):
	_loop_strategy = strategy

func _setup_animation(data: Dictionary) -> float:
	if not data.has('node'):
		 data.node = self.get_parent()

	var node = data.node
	var delay = data.delay if data.has('delay') else 0.0
	var duration = data.duration if data.has('duration') else Anima.DEFAULT_DURATION

	node.set_meta('__pivot_applied', null)
	data._wait_time = max(0.0, data._wait_time + delay)

	if data.has('property') and not data.has('animation'):
		data._is_first_frame = true
		data._is_last_frame = true

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

func _on_timer_timeout() -> void:
	_do_play()

	_loop_times -= 1

	if _loop_times > 0 or _should_loop:
		# Allows to reset the "relative" properties to the value of the 1st loop
		# before doing another loop
		_anima_tween.reset_data(_loop_strategy)

		_do_play()

func _on_all_tween_completed() -> void:
	emit_signal("animation_completed")
	emit_signal("loop_completed", _loop_count)

	if _should_loop:
		_timer.start()
