class_name AnimaRuntime
extends Node

static var _instance: AnimaRuntime = null

var active_playbacks: Array[AnimaPlayback] = []

static func get_singleton() -> AnimaRuntime:
	if _instance == null:
		_instance = AnimaRuntime.new()
		(Engine.get_main_loop() as SceneTree).root.add_child(_instance)
	return _instance

func play(motion: AnimaMotion, target: Node) -> AnimaPlayback:
	var playback := AnimaPlayback.new(motion, target)
	active_playbacks.append(playback)
	playback.finished.connect(func(_success: bool) -> void:
		active_playbacks.erase(playback)
	)
	return playback

func _process(delta: float) -> void:
	for playback in active_playbacks.duplicate():
		playback._advance(delta)
