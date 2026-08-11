## Namespace for [enum Kind] — the anchor positions a scale or rotation motion
## can transform around, instead of the target's default origin
## (`tech-spec.md` §Motion pivot control). A lightweight, non-[Resource]
## helper — like [Motion]/[AnimaEase] — that exists only to hold this enum
## under its own name, since a pivot value is shared by [AnimaPropertyMotion]
## and [AnimaKeyframeMotion]/[AnimaKeyframeStop] and no longer belongs to
## either one specifically (`project-rules.md` §Folder Structure).
class_name AnimaPivot
extends RefCounted

## Restored Anima v1 anchor positions a scale or rotation motion can
## transform around, instead of the target's default origin. Only takes
## effect when the motion's canonical property is
## `scale`/`scale:x`/`scale:y` or `rotation` — see [member AnimaPropertyMotion.pivot]
## (`tech-spec.md` §Motion pivot control).
enum Kind {
	## No pivot override — the target's default transform origin is used.
	NONE,
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT,
}
