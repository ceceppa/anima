## Lists categories and preset names for the Animation Catalog Playground by
## scanning `res://addons/anima/presets/` directly — scene-local, not part
## of Anima's public API (tech-spec.md §Animation catalog, "Catalog
## enumeration is not part of Anima's public API"). Scans on every call
## rather than caching, so a preset added mid-session shows up without a
## restart.
class_name AnimationCatalogIndex
extends RefCounted

const PRESETS_ROOT := "res://addons/anima/presets/"

## Every immediate subdirectory of [constant PRESETS_ROOT], alphabetically
## sorted — the catalog's category names.
static func categories() -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(PRESETS_ROOT)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry_name := dir.get_next()
	while entry_name != "":
		if dir.current_is_dir() and not entry_name.begins_with("."):
			result.append(entry_name)
		entry_name = dir.get_next()
	dir.list_dir_end()

	result.sort()
	return result

## The `.tres` preset names (extension stripped) directly inside
## `PRESETS_ROOT/[param category]/`, alphabetically sorted. An unrecognised
## [param category] reports an error and returns an empty list.
static func names(category: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(PRESETS_ROOT + category)
	if dir == null:
		push_error("AnimationCatalogIndex.names(): no category \"%s\"." % category)
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			result.append(file_name.get_basename())
		file_name = dir.get_next()
	dir.list_dir_end()

	result.sort()
	return result
