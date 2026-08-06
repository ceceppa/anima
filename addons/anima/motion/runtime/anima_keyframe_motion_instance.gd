## Runtime instance for [AnimaKeyframeMotion] — advances every track together
## against one shared elapsed clock, evaluating each independently.
class_name AnimaKeyframeMotionInstance
extends AnimaMotionInstance

var _elapsed: float = 0.0
var _resolved_duration: float = 0.0
var _duration_resolved: bool = false
## Each track's stops resolved once, in parallel with [member
## AnimaKeyframeMotion.tracks] — a stop whose authored value is an
## [AnimaValue] is resolved here; a literal passes through unchanged. Never
## mutates the authored [AnimaKeyframeStop]s themselves (`project-rules.md`
## §Architecture — resources hold authored config only).
var _resolved_values: Array = []
var _values_resolved: bool = false
var _pivot_applied: bool = false

## Advances this motion by [param delta] seconds and writes every track's
## current value to [param target]. Returns `true` once finished.
func advance(target: Node, delta: float) -> bool:
	var keyframe_motion := motion as AnimaKeyframeMotion

	if not _duration_resolved:
		_resolved_duration = _resolve_duration(target, keyframe_motion)
		_duration_resolved = true
	if not _values_resolved:
		_resolve_values(keyframe_motion, target)
	if not _pivot_applied:
		_resolve_and_apply_pivot(keyframe_motion, target)
		_pivot_applied = true

	_elapsed += delta * motion.speed
	var t: float = 1.0 if _resolved_duration <= 0.0 else clampf(_elapsed / _resolved_duration, 0.0, 1.0)

	for track_index in keyframe_motion.tracks.size():
		var track: AnimaKeyframeTrack = keyframe_motion.tracks[track_index]
		target.set_indexed(track.property_path, _evaluate_track(track, _resolved_values[track_index], keyframe_motion, t))

	return t >= 1.0 or is_equal_approx(t, 1.0)

## Resolves every track's stop values once — [member _resolved_values][i][j]
## is track i's stop j, parallel to [member AnimaKeyframeTrack.stops].
func _resolve_values(keyframe_motion: AnimaKeyframeMotion, target: Node) -> void:
	_resolved_values.clear()
	for track in keyframe_motion.tracks:
		var stop_values: Array = []
		for stop in track.stops:
			stop_values.append(_resolve_dynamic(stop.value, target))
		_resolved_values.append(stop_values)
	_values_resolved = true

## Resolves the one pivot value this motion uses (`tech-spec.md` §Keyframe
## motions, "Pivot"): scans [param keyframe_motion]'s tracks in order, each
## track's stops in offset order, for the first non-`null` [member
## AnimaKeyframeStop.pivot]; falls back to [member
## AnimaKeyframeMotion.default_pivot] when none is declared anywhere. Applies
## it via the shared [method AnimaMotionInstance._apply_pivot_to] only when
## the resolved pivot isn't [constant AnimaPropertyMotion.Pivot.NONE] and at
## least one track's canonical property is `scale`/`rotation` — the same
## gate [method AnimaPropertyMotionInstance._apply_pivot] uses.
func _resolve_and_apply_pivot(keyframe_motion: AnimaKeyframeMotion, target: Node) -> void:
	var declared_pivot: Variant = null
	for track in keyframe_motion.tracks:
		for stop in track.stops:
			if stop.pivot != null:
				declared_pivot = stop.pivot
				break
		if declared_pivot != null:
			break

	var resolved_pivot: AnimaPropertyMotion.Pivot = declared_pivot if declared_pivot != null else keyframe_motion.default_pivot
	if resolved_pivot == AnimaPropertyMotion.Pivot.NONE:
		return

	var applies_to_a_track := false
	for track in keyframe_motion.tracks:
		var base_property := String(track.property_path).split(":")[0]
		if base_property == "scale" or base_property == "rotation":
			applies_to_a_track = true
			break
	if not applies_to_a_track:
		return

	_apply_pivot_to(target, resolved_pivot)

## Restores every track's starting value — for [method AnimaPlayback.revert]
## and a [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL]
## outcome. Resolves first if nothing has advanced yet, the same way [method
## force_complete] does, so a dynamic-valued stop is never applied unresolved.
func restore_initial(target: Node) -> void:
	var keyframe_motion := motion as AnimaKeyframeMotion
	if not _values_resolved:
		_resolve_values(keyframe_motion, target)
	for track_index in keyframe_motion.tracks.size():
		target.set_indexed(keyframe_motion.tracks[track_index].property_path, _resolved_values[track_index][0])

## Forces every track to its authored end value immediately — for [method
## AnimaPlayback.complete] and a [constant AnimaMotion.CompletionValuePolicy]
## outcome; resolves first if nothing has advanced yet (see [method restore_initial]).
func force_complete(target: Node) -> void:
	var keyframe_motion := motion as AnimaKeyframeMotion
	if not _values_resolved:
		_resolve_values(keyframe_motion, target)
	for track_index in keyframe_motion.tracks.size():
		var stop_values: Array = _resolved_values[track_index]
		target.set_indexed(keyframe_motion.tracks[track_index].property_path, stop_values[stop_values.size() - 1])

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
## after the last, clamps to that boundary stop's resolved value (no
## extrapolation); a single-stop track holds its one value for the whole
## motion; otherwise interpolates between the bracketing pair's resolved
## values using the arriving stop's own easing, or [member
## AnimaKeyframeMotion.default_ease] when it has none. [param resolved_values]
## is this track's own entry in [member _resolved_values] — parallel to
## [param track]'s own [member AnimaKeyframeTrack.stops].
func _evaluate_track(track: AnimaKeyframeTrack, resolved_values: Array, keyframe_motion: AnimaKeyframeMotion, t: float) -> Variant:
	var stops := track.stops
	if stops.size() == 1:
		return resolved_values[0]
	if t <= stops[0].offset:
		return resolved_values[0]
	if t >= stops[stops.size() - 1].offset:
		return resolved_values[stops.size() - 1]

	for i in range(stops.size() - 1):
		var stop_a: AnimaKeyframeStop = stops[i]
		var stop_b: AnimaKeyframeStop = stops[i + 1]
		if t >= stop_a.offset and t <= stop_b.offset:
			var u: float = 0.0 if is_equal_approx(stop_a.offset, stop_b.offset) \
				else (t - stop_a.offset) / (stop_b.offset - stop_a.offset)
			var ease: AnimaEase = stop_b.ease if stop_b.ease != null else keyframe_motion.default_ease
			return lerp(resolved_values[i], resolved_values[i + 1], ease.evaluate(u))

	return resolved_values[stops.size() - 1]

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
