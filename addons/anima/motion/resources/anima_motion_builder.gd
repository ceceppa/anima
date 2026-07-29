class_name Motion
extends RefCounted

static func sequence(children: Array[AnimaMotion]) -> AnimaSequence:
	var motion := AnimaSequence.new()
	motion.children = children
	return motion

static func parallel(children: Array[AnimaMotion]) -> AnimaParallel:
	var motion := AnimaParallel.new()
	motion.children = children
	return motion

static func stagger(targets: Array[Node], template: AnimaMotion, interval: float) -> AnimaStagger:
	var motion := AnimaStagger.new()
	motion.targets = targets
	motion.template = template
	motion.interval = interval
	return motion

static func repeat(child: AnimaMotion, count: int) -> AnimaRepeat:
	var motion := AnimaRepeat.new()
	motion.child = child
	motion.count = count
	return motion

static func race(children: Array[AnimaMotion]) -> AnimaRace:
	var motion := AnimaRace.new()
	motion.children = children
	return motion

static func conditional(condition: Callable, when_true: AnimaMotion, when_false: AnimaMotion) -> AnimaConditional:
	var motion := AnimaConditional.new()
	motion.condition = condition
	motion.when_true = when_true
	motion.when_false = when_false
	return motion

static func to(target_property: NodePath, to_value: Variant) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = target_property
	motion.to_value = to_value
	return motion
