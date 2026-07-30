extends "res://addons/gut/test.gd"

const SCAN_DIRS := [
	"res://addons/anima/motion/resources/",
	"res://addons/anima/motion/runtime/",
]

## A public, top-level (zero-indent) class_name/func/var/const/signal/enum
## declaration, one per flagged line, that has no `##` doc comment on the
## line immediately above it. Local variables inside a function body are
## indented, so they're correctly excluded — only real class members count.
func _undocumented_lines(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	var lines: Array[String] = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()

	var annotation_regex := RegEx.new()
	annotation_regex.compile("^@[A-Za-z_]+(\\([^)]*\\))?\\s+")

	var flagged: Array = []
	for i in range(lines.size()):
		var line := lines[i]
		if line.is_empty() or line.begins_with("\t") or line.begins_with(" "):
			continue

		var stripped := line.strip_edges()
		# `@export var x`, `@onready var y`, etc. — the annotation prefixes the
		# real declaration on the same line; strip it before matching below.
		var annotation_match := annotation_regex.search(stripped)
		if annotation_match != null:
			stripped = stripped.substr(annotation_match.get_end())

		var name := ""
		var is_declaration := false

		if stripped.begins_with("class_name "):
			is_declaration = true
			name = "class_name"
		else:
			for prefix in ["func ", "var ", "const ", "signal ", "enum "]:
				if stripped.begins_with(prefix):
					is_declaration = true
					name = stripped.substr(prefix.length()).split(" ")[0].split(":")[0].split("(")[0]
					break

		if not is_declaration or name.begins_with("_"):
			continue

		var previous := i - 1
		if previous < 0 or not lines[previous].strip_edges().begins_with("##"):
			flagged.append("%s:%d: %s" % [path, i + 1, stripped])

	return flagged

func test_every_public_declaration_has_a_doc_comment():
	var flagged: Array = []
	for dir_path in SCAN_DIRS:
		var dir := DirAccess.open(dir_path)
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				flagged.append_array(_undocumented_lines(dir_path + file_name))
			file_name = dir.get_next()
		dir.list_dir_end()

	assert_eq(flagged, [], "undocumented public declarations:\n" + "\n".join(flagged))
