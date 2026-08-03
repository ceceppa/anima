## Finds which of an object's exported properties are typed as [AnimaMotion]
## (or a subtype) — the detection [AnimaMotionInspectorPlugin] uses to decide
## whether an ordinary node gets an "Anima" Inspector entry point
## (`tech-spec.md` §Motion Composer entry point). A plain `RefCounted`
## helper, not an `EditorInspectorPlugin`, so it can be exercised directly
## outside a real editor session.
class_name AnimaMotionFieldScanner
extends RefCounted

## Names of [param object]'s exported properties typed as [AnimaMotion] or a subtype.
static func motion_fields(object: Object) -> Array[String]:
	var fields: Array[String] = []
	for property in object.get_property_list():
		if not (property.usage & PROPERTY_USAGE_EDITOR):
			continue
		if property.type == TYPE_OBJECT and property.hint == PROPERTY_HINT_RESOURCE_TYPE \
				and _is_anima_motion_class(property.hint_string):
			fields.append(property.name)
	return fields

## Whether [param class_name_string] is AnimaMotion or a script subclass of it.
## AnimaMotion is a GDScript global class, not a ClassDB-registered engine
## class, so inheritance is walked through ProjectSettings' global class list
## instead of ClassDB.is_parent_class().
static func _is_anima_motion_class(class_name_string: String) -> bool:
	var current := class_name_string
	var seen := {}
	while not current.is_empty() and not seen.has(current):
		if current == "AnimaMotion":
			return true
		seen[current] = true
		current = _base_of(current)
	return false

static func _base_of(class_name_string: String) -> String:
	for entry in ProjectSettings.get_global_class_list():
		if entry.class == class_name_string:
			return entry.base
	return ""
