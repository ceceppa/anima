class_name AnimaRuntime
extends Node

static var _instance: AnimaRuntime = null

var active_playbacks: Array[AnimaPlayback] = []

static func get_singleton() -> AnimaRuntime:
	if _instance == null:
		_instance = AnimaRuntime.new()
		# Deferred: the first Anima.play() call often happens inside a node's
		# own _ready(), while the scene tree root is still mid-add_child() for
		# the scene itself — a direct add_child() here would be rejected.
		(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(_instance)
	return _instance

func play(motion: AnimaMotion, target: Node = null) -> AnimaPlayback:
	var playback := AnimaPlayback.new(motion, target)
	active_playbacks.append(playback)
	playback.finished.connect(func(_success: bool) -> void:
		active_playbacks.erase(playback)
	)
	return playback

func _process(delta: float) -> void:
	for playback in active_playbacks.duplicate():
		playback._advance(delta)
