class_name AnimaDuration
extends RefCounted

## Order matters: higher enum value = "worse" (less certain), used by worst_kind().
enum Kind {
	FIXED,
	ESTIMATED,
	DYNAMIC,
	INFINITE,
}

var kind: Kind = Kind.FIXED
var seconds: float = 0.0

func _init(p_kind: Kind = Kind.FIXED, p_seconds: float = 0.0) -> void:
	kind = p_kind
	seconds = p_seconds

static func fixed(p_seconds: float) -> AnimaDuration:
	return AnimaDuration.new(Kind.FIXED, p_seconds)

static func dynamic() -> AnimaDuration:
	return AnimaDuration.new(Kind.DYNAMIC, 0.0)

## Worst-kind-wins: the least certain kind among a composite's children.
static func worst_kind(durations: Array[AnimaDuration]) -> Kind:
	var result := Kind.FIXED
	for duration in durations:
		if duration.kind > result:
			result = duration.kind
	return result
