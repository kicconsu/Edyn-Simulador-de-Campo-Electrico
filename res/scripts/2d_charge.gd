@tool
extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)

@onready var mesh:MeshInstance2D = $MeshInstance2D
@onready var collision_shape:CollisionShape2D = $CollisionShape2D
#@onready var sliders_scene = get_node("/root/2dTest/Node2D/Control")

var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)

func _ready():
	self.collision_shape.set_shape(self.collision_shape.get_shape().duplicate(true))
	self.mesh.set_mesh(self.mesh.get_mesh().duplicate(true))


func _process(_delta):
	#Modulate Color 
	if (self.char > 0):
		self.mesh.set_self_modulate(Color('#ff2165'))
	else:
		self.mesh.set_self_modulate(Color('#5087ff'))
	
	match self.type:
		0: #Carga puntual
			if(not is_instance_of(mesh.mesh, SphereMesh)):
				mesh.set_mesh(SphereMesh.new())
				mesh.mesh.radial_segments = 4
				mesh.mesh.rings = 5
			mesh.mesh.radius = 7
			mesh.mesh.height = 14
			collision_shape.shape.size = Vector2(14, 14)
			
		1: #Cable
			if(not is_instance_of(mesh.mesh, BoxMesh)):
				mesh.set_mesh(BoxMesh.new())
			mesh.mesh.size = Vector3(self.info[0], 20, 1)
			collision_shape.shape.size = Vector2(self.info[0], 15)
		2: #Disco
			if(not is_instance_of(mesh.mesh, SphereMesh)):
				mesh.set_mesh(SphereMesh.new())
				mesh.mesh.radial_segments = 4
				mesh.mesh.rings = 5
			mesh.mesh.radius = self.info[1]
			mesh.mesh.height = self.info[1]*2
			collision_shape.shape.size = Vector2(self.info[1]*2, self.info[1]*2)
		3: #Anillo
			pass
		4: #Rect
			if(not is_instance_of(mesh.mesh, BoxMesh)):
				mesh.set_mesh(BoxMesh.new())
			mesh.mesh.size = Vector3(self.info[0], self.info[1], 1)
			collision_shape.shape.size = Vector2(self.info[0], self.info[1])
			

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		print("mouse button event")
		print("hovered? ", hovered)
		print("picked? ", picked)
		print(event.button_index == 1, event is InputEventMouseButton, hovered)
	
	if event is InputEventMouseButton and hovered:
		print("clicked and hovered")
		if picked:
			self.hovered = !self.hovered #Make the mouse re-enter charge area if it just dropped it
		self.picked = !self.picked
		print("picked? ", picked)
		
	if event is InputEventMouseButton and picked and not hovered:
		print("clicked and picked but not hovered")
		self.picked = false
		print("picked? ", picked)
	
	if event is InputEventMouseMotion and picked:
			self.position = get_global_mouse_position()
			
	

func _on_mouse_entered() -> void:
	print("Mouse entered")
	self.hovered = true
	
func _on_mouse_exited() -> void:
	print("Mouse exited")
	self.hovered = false
