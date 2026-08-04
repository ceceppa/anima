## Lazily-created runtime singleton that owns the central per-frame evaluation
## loop. No [code]project.godot[/code] autoload entry required — see
## [method get_singleton].
class_name AnimaRuntime
extends Node

static var _instance: AnimaRuntime = null

## Every playback currently in progress.
var active_playbacks: Array[AnimaPlayback] = []

## Returns the lazily-created runtime instance, creating it on first call.
static func get_singleton() -> AnimaRuntime:
	if _instance == null:
		_instance = AnimaRuntime.new()
		# Explicit rather than the PROCESS_MODE_INHERIT default: this singleton
		# attaches directly under the true scene tree root, so an inherited mode
		# would otherwise depend on whatever that root's own process_mode
		# happens to be (host-application-specific, not something Anima owns) —
		# stopping when the tree pauses is Anima's own lifecycle-safe default
		# (tech-spec.md §Lifecycle-safe playback policies), not a inherited accident.
		_instance.process_mode = Node.PROCESS_MODE_PAUSABLE
		# Deferred: the first Anima.play() call often happens inside a node's
		# own _ready(), while the scene tree root is still mid-add_child() for
		# the scene itself — a direct add_child() here would be rejected.
		(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(_instance)
	return _instance

## Starts playing [param motion] against [param target] and tracks it in
## [member active_playbacks] until it finishes.
func play(motion: AnimaMotion, target: Node = null) -> AnimaPlayback:
	return _track(AnimaPlayback.new(motion, target))

## Same as [method play], except playback begins already running backward —
## see [method AnimaPlayback._init]'s `p_start_reversed` and [method Anima.play_backwards].
func play_backwards(motion: AnimaMotion, target: Node = null) -> AnimaPlayback:
	return _track(AnimaPlayback.new(motion, target, true))

func _track(playback: AnimaPlayback) -> AnimaPlayback:
	playback._runtime = self
	active_playbacks.append(playback)
	playback.finished.connect(func(_success: bool) -> void:
		active_playbacks.erase(playback)
	)
	return playback

## Re-adds [param playback] to [member active_playbacks] if it isn't already
## there. A playback that already finished or was cancelled was removed (see
## [method _track]) so it stops being advanced every frame; [method
## AnimaPlayback.reverse] calls this to resume being ticked after it sets the
## playback back to [constant AnimaPlayback.State.PLAYING] — otherwise
## nothing would ever call [method AnimaPlayback._advance] on it again.
func ensure_tracked(playback: AnimaPlayback) -> void:
	if not active_playbacks.has(playback):
		active_playbacks.append(playback)

func _process(delta: float) -> void:
	for playback in active_playbacks.duplicate():
		playback._advance(delta)
