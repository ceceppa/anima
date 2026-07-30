class_name Anima
extends RefCounted

static func play(motion: AnimaMotion, target: Node) -> AnimaPlayback:
	return AnimaRuntime.get_singleton().play(motion, target)
