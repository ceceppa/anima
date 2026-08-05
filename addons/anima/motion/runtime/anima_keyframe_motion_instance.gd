## Runtime instance for [AnimaKeyframeMotion] — advances every track together
## against one shared elapsed clock, evaluating each independently.
class_name AnimaKeyframeMotionInstance
extends AnimaMotionInstance

var _elapsed: float = 0.0
var _resolved_duration: float = 0.0
var _duration_resolved: bool = false

## Advances this motion by [param delta] seconds and writes every track's
## current value to [param target]. Returns `true` once finished.
func advance(target: Node, delta: float) -> bool:
	var keyframe_motion := motion as AnimaKeyframeMotion

	if not _duration_resolved:
		_resolved_duration = _resolve_duration(target, keyframe_motion)
		_duration_resolved = true

	_elapsed += delta * motion.speed
	var t: float = 1.0 if _resolved_duration <= 0.0 else clampf(_elapsed / _resolved_duration, 0.0, 1.0)

	for track in keyframe_motion.tracks:
		target.set_indexed(track.property_path, _evaluate_track(track, keyframe_motion, t))

	return t >= 1.0 or is_equal_approx(t, 1.0)

## Restores every track's starting value — for [method AnimaPlayback.revert]
## and a [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL]
## outcome. Keyframe values are always literal this phase, so a track's first
## stop *is* its starting value — no separate capture-on-first-advance step
## is needed the way [AnimaPropertyMotionInstance] needs one for an omittable
## `from_value`.
func restore_initial(target: Node) -> void:
	var keyframe_motion := motion as AnimaKeyframeMotion
	for track in keyframe_motion.tracks:
		target.set_indexed(track.property_path, track.stops[0].value)

## Forces every track to its authored end value immediately — for [method
## AnimaPlayback.complete] and a [constant AnimaMotion.CompletionValuePolicy]
## outcome; see [method restore_initial] for why no captured state is needed.
func force_complete(target: Node) -> void:
	var keyframe_motion := motion as AnimaKeyframeMotion
	for track in keyframe_motion.tracks:
		target.set_indexed(track.property_path, track.stops[track.stops.size() - 1].value)

## Resolves the duration this run actually uses — the same chain
## [method AnimaPropertyMotionInstance._resolve_duration] applies: an
## explicitly positive [member AnimaKeyframeMotion.duration] wins outright;
## otherwise [param target]'s attached [AnimaBehaviour.default_duration],
## else the project-level [member Anima.default_duration].
func _resolve_duration(target: Node, keyframe_motion: AnimaKeyframeMotion) -> float:
	if keyframe_motion.duration > 0.0:
		return keyframe_motion.duration

	var behaviour := Anima.get_behaviour(target)
	if behaviour != null:
		return behaviour.default_duration
	return Anima.default_duration

## Evaluates one track at global progress [param t]: before the first stop or
## after the last, clamps to that boundary stop's value (no extrapolation); a
## single-stop track holds its one value for the whole motion; otherwise
## interpolates between the bracketing pair using the arriving stop's own
## easing, or [member AnimaKeyframeMotion.default_ease] when it has none.
func _evaluate_track(track: AnimaKeyframeTrack, keyframe_motion: AnimaKeyframeMotion, t: float) -> Variant:
	var stops := track.stops
	if stops.size() == 1:
		return stops[0].value
	if t <= stops[0].offset:
		return stops[0].value
	if t >= stops[stops.size() - 1].offset:
		return stops[stops.size() - 1].value

	for i in range(stops.size() - 1):
		var stop_a: AnimaKeyframeStop = stops[i]
		var stop_b: AnimaKeyframeStop = stops[i + 1]
		if t >= stop_a.offset and t <= stop_b.offset:
			var u: float = 0.0 if is_equal_approx(stop_a.offset, stop_b.offset) \
				else (t - stop_a.offset) / (stop_b.offset - stop_a.offset)
			var ease: AnimaEase = stop_b.ease if stop_b.ease != null else keyframe_motion.default_ease
			return lerp(stop_a.value, stop_b.value, ease.evaluate(u))

	return stops[stops.size() - 1].value

## Builds a reversed [AnimaKeyframeMotion]: every stop's offset becomes
## `1.0 - offset`, but easing *ownership* also shifts by one stop, not just
## mirrors in place — the segment that used to run `stop_i -> stop_{i+1}`
## (eased by `stop_{i+1}`'s effective easing) now runs the other way, so the
## easing moves to the new stop built from `stop_i`, mirrored. Walking the
## original stops from last to first already produces offset-ascending order
## once transformed, so no separate sort is needed. Unlike a captured-value
## reversal, nothing needs to have played yet — every value a keyframe motion
## needs is already in its authored tracks.
func build_reversed() -> AnimaMotion:
	var keyframe_motion := motion as AnimaKeyframeMotion
	var reversed := AnimaKeyframeMotion.new()
	reversed.duration = keyframe_motion.duration
	reversed.default_ease = keyframe_motion.default_ease.mirrored()
	reversed.speed = keyframe_motion.speed
	reversed.forward_speed = keyframe_motion.forward_speed
	reversed.reverse_speed = keyframe_motion.reverse_speed
	reversed.on_started_callback = keyframe_motion.on_started_callback
	reversed.on_completed_callback = keyframe_motion.on_completed_callback

	for track in keyframe_motion.tracks:
		var reversed_track := AnimaKeyframeTrack.new()
		reversed_track.property_path = track.property_path

		var stops := track.stops
		var last_index := stops.size() - 1
		for i in range(last_index, -1, -1):
			var new_stop := AnimaKeyframeStop.new()
			new_stop.offset = 1.0 - stops[i].offset
			new_stop.value = stops[i].value
			if i < last_index:
				var donor: AnimaKeyframeStop = stops[i + 1]
				var effective_ease: AnimaEase = donor.ease if donor.ease != null else keyframe_motion.default_ease
				new_stop.ease = effective_ease.mirrored()
			reversed_track.stops.append(new_stop)

		reversed.tracks.append(reversed_track)

	return reversed
