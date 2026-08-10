## Scripted, self-contained scene for social-media capture — plays the full
class_name GridShowcase
extends Control


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout

	_run_show()

func _wait_for_next(timeout := 0.1):
	await get_tree().create_timer(timeout).timeout

## Plays every scene in order, each one starting only once the previous
## scene's own [AnimaPlayback] has finished — the show's one entry point,
## called from [method _ready] for real playback and directly by tests for
## deterministic, signal-driven advancement (class doc).
func _run_show() -> void:
	await %Scene1.play().finished
	await _wait_for_next(1)

	await _zoom_in(%Scene1, %Scene2).finished
	
	await _wait_for_next(2)
	await %Scene2.play()
	
	%Scene3.play()

func _zoom_in(top_node: Control, bottom_node: Control) -> AnimaPlayback:
	var duration = 0.3

	var zoom1 := Anima.on(top_node).keyframes({
		"to": {
			"scale": Vector2(2.0, 2.0),
			"opacity": 0.0
		}
	}).with_duration(duration).with_pivot(AnimaPropertyMotion.Pivot.CENTER).with_ease(AnimaEase.Kind.EXPONENTIAL)

	var zoom2 := Anima.on(bottom_node).keyframes({
		"from": {
			"scale": Vector2(0.8, 0.8),
			"opacity": 0.0
		},
		"to": {
			"scale": Vector2.ONE,
			"opacity": 1.0
		}
	}).with_duration(duration).with_pivot(AnimaPropertyMotion.Pivot.CENTER).with_ease(AnimaEase.Kind.EXPONENTIAL)
	zoom2.delay = 0.05

	Anima.play(zoom1, top_node)
	return Anima.play(zoom2, bottom_node)
