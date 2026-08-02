## Describes how a staggered group spreads its starts across its visible items.
##
## A group animation starts one shared motion on many nodes. Choose a fixed gap
## when each item should wait the same amount, or a total duration when the
## first and last items should fit inside one overall spread.
##
## ```gdscript
## var distribution := AnimaGroupDistribution.new()
## distribution.stagger_interval = 0.08
## ```
class_name AnimaGroupDistribution
extends Resource

## Chooses whether a stagger uses one fixed gap or one total spread duration.
enum Mode {
	FIXED_INTERVAL,
	TOTAL_DURATION,
}

## The way a stagger calculates its visible start delays.
@export var mode: Mode = Mode.FIXED_INTERVAL
## The delay between neighbouring stagger positions when [member mode] is
## [constant Mode.FIXED_INTERVAL].
@export var stagger_interval: float = 0.05
## The delay from the first to last stagger position when [member mode] is
## [constant Mode.TOTAL_DURATION].
@export var total_stagger_duration: float = 0.0
## Optional curve used to distribute starts between the first and last item.
@export var ease: AnimaEase = null

## Returns messages describing settings that cannot produce a visible schedule.
func validate() -> Array[String]:
	var errors: Array[String] = []
	if stagger_interval < 0.0:
		errors.append("stagger_interval must be zero or greater")
	if total_stagger_duration < 0.0:
		errors.append("total_stagger_duration must be zero or greater")
	return errors
