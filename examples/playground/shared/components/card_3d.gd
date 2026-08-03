## The 3D counterpart of the shared 2D Card — an Icosahedron styled after
## v2_stuff/icosahedron.png's faceted-glass look, recoloured to the app's own
## accent palette instead of the reference's green (design-brief.md
## §Component guide "3D Card"). set_progress(t) is its one visual driver,
## mirroring Card.set_progress(t) (project-rules.md §Example Scenes).
class_name Card3D
extends Node3D

@onready var _mesh_instance: MeshInstance3D = %MeshInstance
@onready var _material: ShaderMaterial = _mesh_instance.material_override as ShaderMaterial

var progress: float = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		if _material != null:
			_apply_progress_appearance()

func _ready() -> void:
	_apply_progress_appearance()

## The single visual driver, mirroring [method Card.set_progress]: `0` is at
## rest, `1` is fully complete. Emissive intensity, fresnel strength, and a
## small scale pulse all come continuously from this one value — nothing
## snaps at any point along the way, including the end.
func set_progress(t: float) -> void:
	progress = t

func _apply_progress_appearance() -> void:
	_material.set_shader_parameter("progress", progress)
	var bump := 1.0 + 0.08 * sin(progress * PI)
	scale = Vector3.ONE * bump
