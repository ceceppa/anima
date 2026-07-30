## Lightweight proxy returned by [method Anima.of] — animates a single node
## directly, without the caller building an [AnimaMotion] resource by hand.
class_name AnimaNodeProxy
extends RefCounted

## Default duration used by [method to] / [method transition_to] / [method enter]
## / [method exit] when the caller doesn't provide one.
const DEFAULT_DURATION := 0.3

## The node this proxy animates.
var target: Node

func _init(p_target: Node) -> void:
	target = p_target

## The default ease ([constant AnimaEase.Kind.SINE]) used when the caller
## doesn't provide one. A GDScript `const` can't hold a Resource instance, so
## this is a factory returning a fresh instance per call rather than a shared
## constant.
static func default_ease() -> AnimaEase:
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.SINE
	return ease

## Animates a single [param property] on [member target] to [param to_value].
func to(property: NodePath, to_value: Variant, duration: float = DEFAULT_DURATION, ease: AnimaEase = null) -> AnimaPlayback:
	var motion := Motion.to(property, to_value).with_duration(duration).with_ease(ease if ease != null else default_ease())
	return Anima.play(motion, target)

## Animates every property in [param properties] (`{NodePath: Variant}`) on
## [member target] together, completing when the slowest one does.
func transition_to(properties: Dictionary, duration: float = DEFAULT_DURATION, ease: AnimaEase = null) -> AnimaPlayback:
	var resolved_ease := ease if ease != null else default_ease()
	var children: Array[AnimaMotion] = []
	for property in properties:
		children.append(Motion.to(property, properties[property]).with_duration(duration).with_ease(resolved_ease))
	return Anima.play(Motion.parallel(children), target)

## Fades [member target] in (`modulate:a` from `0.0` to `1.0`) using a
## built-in default motion. Reading `motion_in` from an attached
## [code]AnimaBehaviour[/code] instead is separate, later work.
func enter() -> AnimaPlayback:
	var motion := Motion.to(NodePath("modulate:a"), 1.0).with_duration(DEFAULT_DURATION).with_ease(default_ease())
	motion.from_value = 0.0
	return Anima.play(motion, target)

## Fades [member target] out (`modulate:a` toward `0.0`) using the same
## built-in default as [method enter], in reverse.
func exit() -> AnimaPlayback:
	var motion := Motion.to(NodePath("modulate:a"), 0.0).with_duration(DEFAULT_DURATION).with_ease(default_ease())
	return Anima.play(motion, target)
