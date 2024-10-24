@tool
extends Node3D

# Gui and Camera Variables
@onready var _3d_charge = $"3dCharge"
@onready var camera_3d = $Camera3D
@onready var animation = $TabMenu/Animation
@onready var projection = $Camera3D/Projection

var toggle : bool
var changeProjection = false

#Script in charge of handling the 3D simulation.
#Mainly, dispatches de 3d_vec_camp shader.

#Shader variables
var shader
var pipeline
var uniform_set
var ecamp_rid : RID
var vecpositions_rid : RID
var bindings : Array
var rd: RenderingDevice = RenderingServer.create_local_rendering_device()
#Inputted position matrix as RGB image
var posmat:Image
#Outputted electric camp matrix as RGB image
var ecamp:Image

#Helper variables
var img_width:int
var img_height:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	camera_3d.set_current(true)
	toggle = false
	
	posmat = $"3dContainer".pos_img
	img_width = posmat.get_width()
	img_height = posmat.get_height()
	setup_compute()
	ecamp = render_ecamp()
	$"3dContainer".offset_vectors(ecamp)
	#TODO: make it so offset_vectors just swaps out the offset_img in the container. let process() do the rest.


func _input(event):
	
	if Input.is_action_just_pressed("changeProjection"):
		if changeProjection:
			projection.play_backwards("changeProjection")
			changeProjection = !changeProjection
		else:
			projection.play("changeProjection")
			changeProjection = !changeProjection
	
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			animation.play("upside")
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			toggle = !toggle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.refresh_uniforms()
	ecamp = render_ecamp()
	$"3dContainer".offset_vectors(ecamp)

func setup_compute() -> void:
	# Create shader from shadefile and create pipeline
	var shader_file = load("res://res/shaders/3d_vec_camp.glsl")
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	pipeline = rd.compute_pipeline_create(shader)
	
	#SSBO SETUP --------------------------------------
	
	#vector positions image SSBO ----------------
	#Format setup:
	var texFormat := RDTextureFormat.new()
	texFormat.width = img_width
	texFormat.height = img_height
	texFormat.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT #Matches the format in the 3d_container_model
	texFormat.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	#Texture and uniform setup:
	var vecpos_uniform := _vecpos_uniform_update(texFormat)
	
	#electric camp image SSBO -------------------
	# -- Reuse texformat --
	#Texture and uniform setup:
	var ecamp_uniform := _ecamp_uniform_update(texFormat)
	
	#charges SSBO
	var charUniform := _charges_uniform_update()
	
	bindings = [
		
		vecpos_uniform,
		ecamp_uniform,
		charUniform
		
	]
	
	uniform_set = rd.uniform_set_create(bindings, shader, 0)

func render_ecamp() -> Image:
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
	ecamp = Image.create_from_data(img_width, img_height, false, Image.FORMAT_RGBAF, outputBytes)
	#_check_pixels(ecamp)
	return ecamp

func refresh_uniforms() -> void:
	var char_uniform:RDUniform = self._charges_uniform_update()
	self.bindings = [
		bindings[0],
		bindings[1],
		char_uniform
	]
	uniform_set = rd.uniform_set_create(bindings, shader, 0)


#Debug function that samples each pixel in the ecamp image and prints its color
func _check_pixels(image:Image) -> void:
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

func _charges_uniform_update() -> RDUniform:
	#gather charges in a list
	var charges:Array[Node] = get_tree().get_nodes_in_group("3D_charges")
	#init byte array
	var chargeBytes := PackedByteArray()
	#add each charge's data to the array
	var c:int = 0
	for charge in charges:
		var chargeTransform:Transform3D = charge.get_global_transform()
		# 12 bytes + 4 packing = 16 - at 0
		chargeBytes.append_array(PackedFloat32Array([chargeTransform.origin.x, chargeTransform.origin.y, chargeTransform.origin.z, -1]).to_byte_array())
		# 16 bytes - at 16
		chargeBytes.append_array(PackedFloat32Array([chargeTransform.basis.y.x, chargeTransform.basis.y.y, chargeTransform.basis.y.z, charge.radius]).to_byte_array())
		# 4 bytes - at 32
		chargeBytes.append_array(PackedFloat32Array([charge.char]).to_byte_array())
		# 4 bytes - at 36 -> add 4*2 padding to end with a size of 48
		chargeBytes.append_array(PackedInt32Array([charge.type, -1, -1]).to_byte_array())
		#print("charge, ", c, " charge: ", charge.char, " type: ", charge.type)
		c += 1
	#Uniform setup
	var charBuffer := rd.storage_buffer_create(chargeBytes.size(), chargeBytes)
	var charUniform := RDUniform.new()
	charUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	charUniform.binding = 2
	charUniform.add_id(charBuffer)
	return charUniform

func _on_cargas_button_pressed():
	animation.play_backwards("upside")
	toggle = false
	var instance = load("res://scenes/subscenes/3d_charge.tscn").instantiate()	
	add_child(instance)
	instance.global_position = Vector3(2.5,2.5,2.5)

		
func _on_varilla_button_pressed():
	animation.play_backwards("upside")
	toggle = false
	var instance = load("res://scenes/subscenes/3d_charge.tscn").instantiate()	
	add_child(instance)
	instance.global_position = Vector3(2.5,2.5,2.5)
	instance.type = 2
	instance.radius = 1
	
func _on_esfera_button_pressed():
	animation.play_backwards("upside")
	toggle = false
	var instance = load("res://scenes/subscenes/3d_charge.tscn").instantiate()	
	add_child(instance)
	instance.global_position = Vector3(2.5,2.5,2.5)
	instance.type = 1
	instance.radius = 1
	
func _on_cilindro_button_pressed():
	animation.play_backwards("upside")
	toggle = false
	var instance = load("res://scenes/subscenes/3d_charge.tscn").instantiate()	
	add_child(instance)
	instance.global_position = Vector3(2.5,2.5,2.5)
	instance.type = 3
	instance.radius = .3

func _on_placa_button_pressed():
	animation.play_backwards("upside")
	toggle = false
	var instance = load("res://scenes/subscenes/3d_charge.tscn").instantiate()	
	add_child(instance)
	instance.global_position = Vector3(0,0,0)
	instance.type = 4
	instance.char = 0.05
	
