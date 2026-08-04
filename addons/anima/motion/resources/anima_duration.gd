## A motion's reported duration: a kind (how certain it is) plus, when known,
## its length in seconds. Returned by [method AnimaMotion.estimate_duration].
class_name AnimaDuration
extends RefCounted

## Order matters: higher enum value = "worse" (less certain), used by worst_kind().
enum Kind {
	FIXED,
	ESTIMATED,
	DYNAMIC,
	INFINITE,
}

## How certain this duration is.
var kind: Kind = Kind.FIXED
## The duration in seconds. Meaningful only for [constant Kind.FIXED] and
## [constant Kind.ESTIMATED]; `0.0` and unused for [constant Kind.DYNAMIC] /
## [constant Kind.INFINITE].
var seconds: float = 0.0

func _init(p_kind: Kind = Kind.FIXED, p_seconds: float = 0.0) -> void:
	kind = p_kind
	seconds = p_seconds

## Builds a [constant Kind.FIXED] duration of [param p_seconds].
static func fixed(p_seconds: float) -> AnimaDuration:
	return AnimaDuration.new(Kind.FIXED, p_seconds)

## Builds a [constant Kind.ESTIMATED] duration of [param p_seconds].
static func estimated(p_seconds: float) -> AnimaDuration:
	return AnimaDuration.new(Kind.ESTIMATED, p_seconds)

## Builds a [constant Kind.DYNAMIC] duration (no known length).
static func dynamic() -> AnimaDuration:
	return AnimaDuration.new(Kind.DYNAMIC, 0.0)

## Builds a [constant Kind.INFINITE] duration (never finishes on its own).
static func infinite() -> AnimaDuration:
	return AnimaDuration.new(Kind.INFINITE, 0.0)

## Worst-kind-wins: the least certain kind among a composite's children.
static func worst_kind(durations: Array[AnimaDuration]) -> Kind:
	var result := Kind.FIXED
	for duration in durations:
		if duration.kind > result:
			result = duration.kind
	return result
