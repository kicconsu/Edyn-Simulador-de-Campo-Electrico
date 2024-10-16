@tool
extends Node3D

@export var size := Vector3(5, 5, 5)
@export var resolution:int = 10
@export var box_color := Color(1, 0, 0)
@export_range(0.001, 0.05) var minthick:float =  0.001
@export_range(0.001, 0.05) var maxthick:float =  0.05
@export_range(0, 20) var alpha_sensitivity:float = 60

var offset_img:Image
var pos_mat:Array
var pos_img:Image

func _ready() -> void:
	
	#Image and Matrix setup
	#Vector start position interval
	var interval := Vector3(self.size.x/resolution, self.size.y/resolution, self.size.z/resolution)
	
	for y in range(resolution):
		pos_mat.append([]) #Starter positions matrix rows have to be initialized beforehand so for loops make sense
	
	for z in range(resolution):
		for y in range(resolution):
			for x in range(resolution):
				pos_mat[y].append(Vector3(Vector3(x, y, z) * interval + self.global_position + Vector3.ONE*(interval/2)))
	
	#Image pixels are to be looked up in 3D as follows: img.get_pixel(x+(z*resolution), y)
	#TODO: Emit signal to refresh image if resolution is changed to avoid lookup errors
	var width:int = resolution*resolution
	var height:int = resolution
	self.offset_img = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	
	self.pos_img = self.mat_to_img(pos_mat)
	
	

func _process(delta: float) -> void:
	var conf:DebugDraw3DScopeConfig = DebugDraw3D.new_scoped_config().set_thickness(0.05)
	DebugDraw3D.draw_box(self.global_position, Quaternion.IDENTITY, self.size, self.box_color, false)
	var interval := Vector3(self.size.x/resolution, self.size.y/resolution, self.size.z/resolution)
	for z in range(resolution):
		for y in range(resolution):
			for x in range(resolution):
				var origin:Vector3 = self.pos_mat[y][x + (resolution*z)]
				var col := self.offset_img.get_pixel(x + (z*resolution), y)
				var offset := Vector3(col.r, col.g, col.b)
				var length:float = offset.length_squared()
				var length_scale:float = lerp(1.0, 0.0, length*2)
				#print(offset)
				conf.set_thickness(clamp(lerp(self.maxthick, self.minthick,length/self.alpha_sensitivity), self.minthick, self.maxthick))
				DebugDraw3D.draw_line(origin, origin+offset, Color(length_scale, 1/length_scale, 0))

func mat_to_img(matrix:Array) -> Image:
	var height = matrix.size()
	var width = matrix[0].size()
	
	# Create an image using RGA32F format for 32-bit floating-point precision per channel
	var image:Image = Image.create(width, height, false, Image.FORMAT_RGBAF)
	
	for y in range(height):
		for x in range(width):
			var coord = matrix[y][x]
			#print("row: ", y, " column: ", x)
			#print("pos: ", coord)
			var r = coord.x  # Use the raw x coordinate in the red channel
			var g = coord.y  # Use the raw y coordinate in the green channel
			var b = coord.z      # Optionally, you can store extra data in blue channel
			var a = 1.0      # Alpha channel is fully opaque
			var color = Color(r, g, b)
			image.set_pixel(x, y, color)
			#print("input img color: ", image.get_pixel(x, y))
	return image

func offset_vectors(ecamp:Image) -> void:
	self.offset_img = ecamp
