extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$GeometryDraw.draw_line_relative(global_position, Vector3.UP*200)
