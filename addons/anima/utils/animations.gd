class_name AnimaAnimationsUtils

const BASE_PATH := 'res://addons/anima/animations/'

static func get_animation_path() -> String:
	return BASE_PATH

static func register_animation(animation_name: String, keyframes: Dictionary) -> void:
	_deregister_animation(animation_name)

	ANIMA._custom_animations[animation_name] = keyframes

static func _deregister_animation(animation_name: String) -> void:
	ANIMA._custom_animations.erase(animation_name)

static func get_available_animations() -> Array:
	var animations_list := ANIMA.get_animations_list()

	if animations_list.size() == 0:
		var list = _get_animations_list()
		var filtered := []

		for file in list:
			if file.find('.gd.') < 0 and file.find(".gd") > 0:
				filtered.push_back(file.replace('.gdc', '.gd'))

		animations_list = filtered
		
		ANIMA.set_animations_list(animations_list)

	return animations_list + ANIMA.get_custom_animations().keys()

static func get_available_animation_by_category() -> Dictionary:
	var animations = get_available_animations()
	var base = get_animation_path()
	var old_category := ''
	var result := {}

	for item in animations:
		var category_and_file = item.replace(base, '').split('/')
		var category = category_and_file[0]
		var file_and_extension = category_and_file[1].split('.')
		var file = file_and_extension[0]

		if not result.has(category):
			result[category] = []

		result[category].push_back(file)

	return result

static func get_animation_keyframes(animation_name: String) -> Dictionary:
	var custom_animations := ANIMA.get_custom_animations()

	if custom_animations.has(animation_name):
		return custom_animations[animation_name]

	var resource_file = _get_animation_script_with_path(animation_name)
	if resource_file:
		var script: RefCounted = load(resource_file).new()
		var keyframes: Dictionary = script.KEYFRAMES

		#
		# This was once "set" inside the keyframes engine, but noticed that could have been more
		# a problem that a solution.
		# For lazyness I'm forcing the built-in animations to have this properties as relative
		# instead of modifying (again) all of them xD
		#
		keyframes.relative = ["x", "y", "z", "position", "position:x", "position:z", "position:y"]
		ANIMA.add_custom_animation(animation_name, keyframes)

		script.unreference()

		return keyframes

	printerr('No animation found with name: ', animation_name)
	print("Available animations:")
	for animation in ANIMA._animations_list:
		var parts = animation.replace("res://addons/anima/animations/", "").split("/")
		var file = parts[1].split(".")[0]
		
		print(file)

	return {}

static func _get_animation_script_with_path(animation_name: String) -> String:
	if not animation_name.ends_with('.gd'):
		animation_name += '.gd'

	animation_name = AnimaStrings.from_camel_to_snack_case(animation_name)

	for file_name in get_available_animations():
		if file_name is String and file_name.ends_with(animation_name):
			return file_name

	return ''

static func is_built_in_animation(animation_name: String) -> bool:
	return ANIMA._animations_list.find(animation_name) >= 0

static func _get_animations_list() -> Array:
	var files = _get_scripts_in_dir(BASE_PATH)
	var filtered := []

	files.sort()
	return files

static func _get_scripts_in_dir(path: String, files: Array = []) -> Array:
	var dir = DirAccess.open(path)

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			if dir.current_is_dir():
				_get_scripts_in_dir(path + file_name + '/', files)
			else:
				files.push_back(path + file_name)

		file_name = dir.get_next()

	return files
