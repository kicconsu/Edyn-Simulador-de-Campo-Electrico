extends Node2D

#Simple script that renders lines based on initial vec positions & vec displacements

var offset:Vector2 = Vector2(1, 1)
var vec_matrix:Array = []
var disp_matrix:Image

func set_vec_matrix(mat:Array) -> void:
	self.vec_matrix = mat
	self.disp_matrix = Image.create_empty(mat[0].size(), mat.size(), false, Image.FORMAT_RGF)
	queue_redraw()

func set_disp_matrix(mat:Image) -> void:
	self.disp_matrix = mat
	queue_redraw()


func _draw() -> void:
	for y in self.vec_matrix.size():
		for x in self.vec_matrix[0].size():
			var vecpos:Vector2 = self.vec_matrix[y][x] #Starting position
			var col:Color = self.disp_matrix.get_pixel(x, y) #Displacement or Length
			var displacement:Vector2 = Vector2(col.r, col.g)
			var dest:Vector2 = displacement + vecpos #Ending position
			
			var length:float = clamp(displacement.length_squared(), 0, 1)
			var vec_color := Color(lerp(0.0, 1.0, length), lerp(1.0, 0.0, length), 0) #Vector color
			
			draw_line(vecpos, dest+offset, vec_color, 1)
