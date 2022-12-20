tool
extends ScrollContainer

signal seek(value)

var INTERVAL := 0.1

onready var _timeline_container = find_node("TimeLineContainer")
onready var _labels_container = find_node("LabelsContainer")

var _items := []
var _total := 0.0
var _indicator := 0.1

func update_timeline(data: Dictionary):
	var frames = data.frames
	var default_duration = data.animation.default_duration

	var start := 0.0

	for frame_index in frames:
		var frame = frames[frame_index]
		var end: float
		var name = ""

		if frame.type == "frame":
			if frame.has("duration") and frame.duration:
				end = float(frame.duration)
			else:
				end = default_duration

			if frame.has("delay") and frame.delay:
				start += frame.delay

			if frame.has("name") and frame.name.length() > 0:
				name = frame.name
			else:
				name = "Frame " + str(frame_index)
		else:
			end = frame.data.delay

		end += start

		_items.push_back({
			type = frame.type,
			start = start,
			end = end,
			duration = end - start,
			name = name
		})

		start = end

	_total = start

	_refresh()

func _refresh() -> void:
	for child in _timeline_container.get_children():
		child.queue_free()

	for child in _labels_container.get_children():
		child.queue_free()

	_update_labels()

	call_deferred("_update_visual_timeline")

func _update_labels():
	var i := 0.0
	var label_width := 36.0

	while i <= _total:
		var label = Label.new()
		label.text = str(i)
		label.rect_min_size.x = label_width
		label.align = HALIGN_CENTER
		label.valign = VALIGN_CENTER
		label.mouse_filter = MOUSE_FILTER_STOP
		label.connect("gui_input", self, "_on_label_gui_input", [i])

		_timeline_container.add_child(label)

		i += INTERVAL

func _update_visual_timeline():
	var index := 0
	var height := 24

	yield(get_tree(), "idle_frame")

	var total_size = $Wrapper.rect_size.x

	for item in _items:
		var x1: float = (item.start / _total) * total_size
		var x2: float = (item.end / _total) * total_size

		var position = Vector2(x1, 0)
		var size = Vector2(x2 - x1, height)
		
		var color_id = index
		if color_id > ANIMA._FRAME_COLORS.size():
			color_id = index % ANIMA._FRAME_COLORS.size()

		var color = ANIMA._FRAME_COLORS[color_id]

		if item.type == "delay":
			continue
		else:
			index += 1

		var label = Label.new()
		label.text = "  " + item.name
		label.rect_position = position
		label.rect_min_size = size
		label.hint_tooltip = item.name + "\n Start: " + str(item.start) + "s\n End: " + str(item.end) + "s\n Duration: " + str(item.duration) + "s"
		label.mouse_filter = MOUSE_FILTER_STOP
		label.valign = VALIGN_CENTER

		_labels_container.add_child(label)

		var style := StyleBoxFlat.new()
		style.bg_color = color

		label.add_stylebox_override("normal", style)

func _on_ZoomIn_pressed():
	INTERVAL -= 0.1
	
	if INTERVAL < 0.1:
		INTERVAL = 0.1

	_refresh()

func _on_ZoomOut_pressed():
	INTERVAL += 0.1
	
	if INTERVAL > 1.0:
		INTERVAL = 1.0

	_refresh()

func _on_label_gui_input(event, step) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("seek", step)
