@tool
extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)
const k: float = 9*pow(10,9)

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
	
	#if event is InputEventMouseButton:
		#print("mouse button event")
		#print("hovered? ", hovered)
		#print("picked? ", picked)
		#print(event.button_index == 1, event is InputEventMouseButton, hovered)
	
	if event is InputEventMouseButton and hovered:
		#print("clicked and hovered")
		if picked:
			self.hovered = !self.hovered #Make the mouse re-enter charge area if it just dropped it
		self.picked = !self.picked
		#print("picked? ", picked)
		
	if event is InputEventMouseButton and picked and not hovered:
		#print("clicked and picked but not hovered")
		self.picked = false
		#print("picked? ", picked)
	
	if event is InputEventMouseMotion and picked:
			self.position = get_global_mouse_position()
			
	

func _on_mouse_entered() -> void:
	#print("Mouse entered")
	self.hovered = true
	
func _on_mouse_exited() -> void:
	#print("Mouse exited")
	self.hovered = false


func calculateElectricField(pos):
	match self.type:
		0: # Carga puntual
			return pointCharge(pos)
		1: # Linea Cargada
			return chargedLine(pos)
		2: # Disco cargado
			return chargedDisk(pos)
		3: # Cilindro infinito
			return Vector2.ZERO
		4: # Rectangulo cargado
			return chargedRectangle(pos)
		5: 
			return Vector2.ZERO
			
func pointCharge(pos):
	var charge = self.char*pow(10,-6)
	var p: Vector2 = pos - self.global_position 
	var r: float = p.length()
			
	if r == 0:
		return Vector2.ZERO
			
	var dir: Vector2 = p.normalized()
	var mag: float = (k*charge/(r*r))
			
	return dir*mag

func chargedRectangle(pos):
	
	var charge = self.char*pow(10,-6)
	
	var du: float = self.info[0] / float(self.info[2])
	var dv: float = self.info[1] / float(self.info[2])
	
	var field = Vector2.ZERO
	
	for i in range(info[2]):
		for j in range(info[2]):
			
			var u = -self.info[0] / 2 +(i+0.5) *du
			var v = -self.info[1] / 2 +(j+0.5) *dv
		
			var p = pos + Vector2(
				u * cos(self.info[3]) - v * sin(self.info[3]),
				u * sin(self.info[3]) + v * cos(self.info[3])
			)
			
			var r_dist = pos - p
			var r = r_dist.length()
			
			if r > 0.0:
				var dir = r_dist.normalized()
				var dE = k * charge * du * dv/ (r*r)
				field += dE * dir
				
	return field
	
func chargedDisk(pos):
	var charge = self.char*pow(10,-6)
	var field = Vector2.ZERO
	
	var dr = self.info[1] / float(self.info[2])
	var dtheta = 2*PI / float(self.info[3])
	
	for i in range(self.info[2]):
		var r = dr * (float(i) + 0.5)
		for j in range(self.info[3]):
			var theta = dtheta * float(j)
			
			var pst = self.global_position + Vector2(r*cos(theta), r*sin(theta))
			
			var dist = pos - pst
			var dist_squared  = dist.dot(dist)
			
			if dist_squared > 0:
				var dir = dist.normalized()
				var dE = k * charge * r * dr * dtheta / dist_squared
				field += dE * dir
				
	return field
	
		
func chargedLine(pos):
	var charge = self.char*pow(10,-6)
	var ri = self.global_position - 0.5 * self.info[0] * Vector2(cos(self.info[1]), sin(self.info[1]))
	var lim = self.info[2] / 2
	var field = Vector2.ZERO
	
	for i in range(-lim, lim +1):
		var l = (float(i) / float(self.info[2])) * self.info[0]
		var l_vec = ri + l * Vector2(cos(self.info[1]),sin(self.info[1]))
		
		var dist = pos - l_vec
		var r = dist.length()
	
		if r > 0:
			var dir = dist.normalized()
			var dE = k * charge / (r*r)
			field += dE * dir
	
	return field
