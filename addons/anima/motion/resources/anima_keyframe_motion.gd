## A CSS-inspired keyframe motion: one or more properties, each animated
## through its own list of stops at normalised offsets across one duration.
##
## Two authoring surfaces produce the exact same resource — a dictionary
## declared all at once, or built up one offset at a time with [method at]:
##
## ```gdscript
## var a := Motion.keyframes({"from": {"opacity": 0.0}, 50: {"opacity": 1.0, "scale": Vector2(1.2, 1.2)}, "to": {"opacity": 1.0, "scale": Vector2.ONE}})
## var b := Motion.keyframes() \
##     .at("from", {"opacity": 0.0}) \
##     .at(50, {"opacity": 1.0, "scale": Vector2(1.2, 1.2)}) \
##     .at("to", {"opacity": 1.0, "scale": Vector2.ONE})
## ```
##
## Developers never call the offset-flattening/parsing logic directly — both
## surfaces above funnel through the same internal merge path, so they always
## agree (tech-spec.md §Keyframe motions).
class_name AnimaKeyframeMotion
extends AnimaMotion

## Semantic keyframe-key names resolved to their canonical property path — the
## same mapping [AnimaOnMotionFactory]'s own named methods use, restated here
## since keyframe declarations are dictionary-key-driven, not method-call-driven.
const _SEMANTIC_PROPERTY_PATHS := {
	"opacity": "modulate:a",
	"position": "position",
	"scale": "scale",
	"rotation": "rotation",
	"color": "modulate",
	"size": "size",
}

## This motion's tracks, one per animated property. Built and owned by the
## parser — see [method at] to add to it directly.
@export var tracks: Array[AnimaKeyframeTrack] = []
## Total duration in seconds. `0.0` resolves through the same duration chain
## [AnimaPropertyMotion] uses (attached [AnimaBehaviour.default_duration],
## else [member Anima.default_duration]) at playback time.
@export var duration: float = 0.0
## Easing used for a stop that doesn't set its own [member AnimaKeyframeStop.ease].
@export var default_ease: AnimaEase = AnimaEase.new()
## Pivot used when no stop declares its own [member AnimaKeyframeStop.pivot]
## (`tech-spec.md` §Keyframe motions, "Pivot").
@export var default_pivot: AnimaPropertyMotion.Pivot = AnimaPropertyMotion.Pivot.NONE

## Merges one authored keyframe declaration into [member tracks] and returns
## self, so calls can keep chaining. [param offsets] is `"from"`, `"to"`, a
## 0-100 number (a percentage), or an [Array] of any of those (a grouped
## declaration — the same [param values] block applies to every resolved
## offset). [param values]' non-underscore keys are property declarations —
## a semantic name ([member _SEMANTIC_PROPERTY_PATHS]) or a raw property
## path; a `_ease` key sets the resulting stop(s)' easing, and a `_pivot`
## key declares a pivot inline with this stop (authoring convenience only —
## pivot still resolves once for the whole motion, see §Keyframe motions).
## Other underscore-prefixed keys (`_hold`, `_marker`, `_callback`) are
## reserved for a future phase and are accepted without error, never treated
## as a property.
func at(offsets: Variant, values: Dictionary) -> AnimaKeyframeMotion:
	var resolved_offsets := _resolve_offsets(offsets)
	var stop_ease: AnimaEase = values.get("_ease")
	var stop_pivot = values.get("_pivot")

	for resolved_offset in resolved_offsets:
		for key in values:
			var key_string := String(key)
			if key_string.begins_with("_"):
				continue

			var track := _track_for(_resolve_property_path(key_string))
			var stop := AnimaKeyframeStop.new()
			stop.offset = resolved_offset
			stop.value = values[key]
			stop.ease = stop_ease
			stop.pivot = stop_pivot
			track.stops.append(stop)
			track.stops.sort_custom(func(a: AnimaKeyframeStop, b: AnimaKeyframeStop) -> bool: return a.offset < b.offset)

	return self

## Sets [member duration] directly. Named `with_duration` rather than
## `duration()` for the same reason as [AnimaPropertyMotion]'s own
## `with_duration`/`with_ease`/`with_delay` — a bare method name would
## collide with the field of the same name. Returns self so calls can keep
## chaining.
func with_duration(value: float) -> AnimaKeyframeMotion:
	duration = value
	return self

## Sets [member default_ease] directly, accepting either a full [AnimaEase]
## or a bare [enum AnimaEase.Kind] (coerced via [method AnimaEase.from] —
## `tech-spec.md` §Easing curve library). Named `with_ease` for the same
## `with_`-prefix reason as [method with_duration]. Returns self so calls can
## keep chaining — e.g. directly onto [method AnimaOnMotionFactory.keyframes]'s
## own returned motion (`tech-spec.md` §Keyframe interface).
func with_ease(value: Variant) -> AnimaKeyframeMotion:
	default_ease = AnimaEase.from(value)
	return self

## Sets [member default_pivot] directly. Named `with_pivot` for the same
## `with_`-prefix reason as [method with_duration]; a separate method from
## [method with_ease] since pivot and easing are unrelated settings that
## happen to share the same resolve-once timing (`tech-spec.md` §Keyframe
## motions, "Pivot"). Returns self so calls can keep chaining.
func with_pivot(value: AnimaPropertyMotion.Pivot) -> AnimaKeyframeMotion:
	default_pivot = value
	return self

## Parses [param source] (the dictionary authoring form) into [member tracks]
## in one pass — one [method at] call per top-level key, in whatever order
## [Dictionary] iteration provides; each track ends up offset-sorted
## regardless, since [method at] always sorts after merging.
func parse_dictionary(source: Dictionary) -> void:
	for key in source:
		at(key, source[key])

func _resolve_offsets(key: Variant) -> Array[float]:
	var result: Array[float] = []
	if key is Array:
		for item in key:
			result.append(_resolve_offset(item))
	else:
		result.append(_resolve_offset(key))
	return result

func _resolve_offset(key: Variant) -> float:
	if key is String:
		match key:
			"from":
				return 0.0
			"to":
				return 1.0
			_:
				push_error("AnimaKeyframeMotion: invalid offset key \"%s\" — expected \"from\", \"to\", or a 0-100 number." % key)
				return 0.0
	if key is int or key is float:
		return float(key) / 100.0
	push_error("AnimaKeyframeMotion: invalid offset key of type %s — expected String, int, or float." % typeof(key))
	return 0.0

func _resolve_property_path(key: String) -> NodePath:
	if _SEMANTIC_PROPERTY_PATHS.has(key):
		return NodePath(_SEMANTIC_PROPERTY_PATHS[key])
	return NodePath(key)

func _track_for(property_path: NodePath) -> AnimaKeyframeTrack:
	for track in tracks:
		if track.property_path == property_path:
			return track
	var track := AnimaKeyframeTrack.new()
	track.property_path = property_path
	tracks.append(track)
	return track

## Reports this motion's duration — the same [code]fixed(duration)[/code]
## pattern [method AnimaPropertyMotion.estimate_duration] uses, including
## reporting `fixed(0.0)` verbatim when [member duration] is still
## chain-resolved rather than explicit.
func estimate_duration() -> AnimaDuration:
	return AnimaDuration.fixed(duration)

## Builds the runtime instance that advances every track together. See
## [method AnimaMotion.create_runtime] for [param context].
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaKeyframeMotionInstance.new(self, context)

## Returns messages describing missing tracks, empty tracks, or duplicate
## stops at the same offset on the same track.
func validate() -> Array[String]:
	var errors: Array[String] = []
	if tracks.is_empty():
		errors.append("at least one track is required")

	for track in tracks:
		if track.stops.is_empty():
			errors.append("track '%s' has no stops" % track.property_path)
			continue
		for i in range(track.stops.size() - 1):
			if is_equal_approx(track.stops[i].offset, track.stops[i + 1].offset):
				errors.append("track '%s' has duplicate stops at offset %s" % [track.property_path, track.stops[i].offset])

	return errors
