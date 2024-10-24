extends Node

@onready var draw: MeshInstance3D = $MeshInstance3D

func _physics_process(_delta: float) -> void:
	if draw.mesh is ImmediateMesh:
		draw.mesh.clear_surfaces()
	
func draw_line(a: Vector3, b: Vector3, color: Color = Color.WHITE):
	if a.is_equal_approx(b):
		return
	
	if draw.mesh is ImmediateMesh:
		draw.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		draw.mesh.surface_set_color(color)
		
		draw.mesh.surface_add_vertex(a)
		draw.mesh.surface_add_vertex(b)
		
		draw.mesh.surface_end()

func draw_line_relative(from: Vector3, offset: Vector3, color: Color = Color.	WHITE):
	draw_line(from, from + offset, color)
