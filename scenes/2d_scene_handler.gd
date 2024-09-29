extends Node2D

#Script in charge of handling the 2D simulation.
#Mainly, dispatches de 2d_vec_camp shader.

#Shader variables
var shader
var pipeline
var uniform_set
var ecamp_rid : RID
var vecpositions_rid : RID
var bindings : Array
var rd: RenderingDevice = RenderingServer.create_local_rendering_device()
#Inputted position matrix as RG image
var posmat:Image
#Outputted electric camp matrix as RG image
var ecamp:Image

#Helper variables
var img_width:int
var img_height:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posmat = $"2dContainer".posImg
	img_width = posmat.get_width()
	img_height = posmat.get_height()
	setupCompute()
	render()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setupCompute():
	# Create shader from shadefile and create pipeline
	var shader_file = load("res://res/shaders/2d_vec_camp.glsl")
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	pipeline = rd.compute_pipeline_create(shader)
	
	#SSBO SETUP --------------------------------------
	
	#vector positions image SSBO ----------------
	#Format setup:
	var texFormat := RDTextureFormat.new()
	texFormat.width = img_width
	texFormat.height = img_height
	texFormat.format = RenderingDevice.DATA_FORMAT_R32G32_SFLOAT #Matches the format in the 2d_container_handler
	texFormat.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	var vecpos_uniform := _vecpos_uniform_update(texFormat)
	
	#electric camp image SSBO -------------------
	# -- Reuse texformat --
	var ecamp_uniform := _ecamp_uniform_update(texFormat)
	
	bindings = [
		
		vecpos_uniform,
		ecamp_uniform
		
	]
	
	uniform_set = rd.uniform_set_create(bindings, shader, 0)

func render():
	# Start compute list to start recording our compute commands
	var compute_list = rd.compute_list_begin()
	
	# Bind the pipeline, this tells the GPU what shader to use
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	# Binds the uniform set with the data we want to give our shader 
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# Dispatch (X,Y,Z) work groups
	rd.compute_list_dispatch(compute_list, max((img_width / 16), 1), max((img_height / 16), 1), 1)
	
	# Tell the GPU we are done with this compute task
	rd.compute_list_end()
	#Force the GPU to start our commands
	rd.submit()
	# Force the CPU to wait for the GPU to finish with the recorded commands
	rd.sync()
	
	# Receive output bytes
	var outputBytes : PackedByteArray = rd.texture_get_data(ecamp_rid, 0)
	ecamp = Image.create_from_data(img_width, img_height, false, Image.FORMAT_RGF, outputBytes)
	_check_pixels(ecamp)

#Debug function that samples each pixel in the ecamp image and prints its color
func _check_pixels(image:Image):
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			#print("output sample at: ", Vector2(x, y))
			print("output img color: ", image.get_pixel(x, y))

#Helper function that returns the vecpos image uniform to be added to the uniform set
func _vecpos_uniform_update(format:RDTextureFormat) -> RDUniform:
	#Texture setup:
	vecpositions_rid = rd.texture_create(format, RDTextureView.new(), [posmat.get_data()])
	#Uniform setup:
	var vecpos_uniform := RDUniform.new()
	vecpos_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	vecpos_uniform.binding = 0
	vecpos_uniform.add_id(vecpositions_rid)
	return vecpos_uniform

#Helper function that returns the electric camp image uniform to be added to the uniform set.
func _ecamp_uniform_update(format:RDTextureFormat) -> RDUniform:
	#Texture setup:
	ecamp_rid = rd.texture_create(format, RDTextureView.new())
	#Uniform setup:
	var ecamp_uniform := RDUniform.new()
	ecamp_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	ecamp_uniform.binding = 1
	ecamp_uniform.add_id(ecamp_rid)
	return ecamp_uniform
