extends Node2D

@export var res:int = 1080
@export var size:Vector2 = Vector2(1000.0, 500.0)
@onready var vec_scene:PackedScene = load("res://scenes/subscenes/2d_arrow.tscn")
var mat:Array = [] #Vector position matrix
var debugTexture:ImageTexture #Texture to house resized positions RG image
var posImg:Image #Texture to house positions RG image that is sent to the GPU (not resized)

func _ready():
	#Instantiate vectors to populate vector camp
	var vec_interval:Vector2 = Vector2(size.x/res, size.y/(res/2))
	for i in range(int(res/2)):
		mat.append([])
		for j in range(res):
			var vec = vec_scene.instantiate()
			add_child(vec)
			vec.set_position(Vector2(vec_interval.x*j, vec_interval.y*i)-size/2+size/50)
			#Save each vector in the vector matrix to generate the posTexture
			mat[i].append(vec.get_position())
		#print(mat[i])
	posImg = mat_to_img(mat) #Generate positions image, where each position is an RG color.
	
	var debugImg:Image = posImg.duplicate()
	
	#Resize it to draw it on the bg for debug purposes
	debugImg.resize(1000, 500)
	debugTexture = ImageTexture.create_from_image(debugImg)
	$bg.set_texture(debugTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Code that takes a matrix of Vector2() and turns it into a RG32F texture
# This texture is to be sent to the GPU so that it can calculate E for each vector
func mat_to_img(matrix:Array) -> Image:
	var height = matrix.size()
	var width = matrix[0].size()
	
	# Create an image using RGA32F format for 32-bit floating-point precision per channel
	var image:Image = Image.create(width, height, false, Image.FORMAT_RGF)
	
	for y in range(height):
		for x in range(width):
			var coord = matrix[y][x]
			#print("row: ", y, " column: ", x)
			#print("pos: ", coord)
			var r = coord.x  # Use the raw x coordinate in the red channel
			var g = coord.y  # Use the raw y coordinate in the green channel
			var b = 0.0      # Optionally, you can store extra data in blue channel
			var a = 1.0      # Alpha channel is fully opaque
			var color = Color(r, g, b)
			image.set_pixel(x, y, color)
			print("input img color: ", image.get_pixel(x, y))
	#return ImageTexture.new().create_from_image(image)
	return image
