@tool
extends Node3D

@export var type:int = 0
@export var char:float = 1
@export var radius:float = 2
@onready var mesh:CSGMesh3D = $CSGMesh3D

func _ready() -> void:
	self.mesh.material = self.mesh.material.duplicate(true)

func _process(_delta: float) -> void:
	
	if(self.char > 0):
		self.mesh.material.next_pass.albedo_color = '#ff2165'
	else:
		self.mesh.material.next_pass.albedo_color = '#5087ff'
		
	if(self.type == 0):
		if(not is_instance_of(mesh.mesh, SphereMesh)):
			mesh.set_mesh(SphereMesh.new())
			mesh.mesh.radial_segments = 10
			mesh.mesh.rings = 5
		mesh.mesh.radius = 0.3
		mesh.mesh.height = 0.3*2
	elif(self.type == 1):
		if(not is_instance_of(mesh.mesh, SphereMesh)):
			mesh.set_mesh(SphereMesh.new())
			mesh.mesh.radial_segments = 10
			mesh.mesh.rings = 5
		mesh.mesh.radius = self.radius/10
		mesh.mesh.height = mesh.mesh.radius*2
	elif(self.type == 2):
		if(not is_instance_of(mesh.mesh, CylinderMesh)):
			mesh.set_mesh(CylinderMesh.new())
			mesh.mesh.height = 1000
			mesh.mesh.cap_top = false
			mesh.mesh.cap_bottom = false
			mesh.mesh.radial_segments = 5
		mesh.mesh.top_radius = 0.1
		mesh.mesh.bottom_radius = 0.1
	elif(self.type == 3):
		if(not is_instance_of(mesh.mesh, CylinderMesh)):
			mesh.set_mesh(CylinderMesh.new())
			mesh.mesh.height = 1000
			mesh.mesh.cap_top = false
			mesh.mesh.cap_bottom = false
			mesh.mesh.radial_segments = 5
		mesh.mesh.top_radius = self.radius*3
		mesh.mesh.bottom_radius = self.radius*3
	elif(self.type == 4):
		if(not is_instance_of(mesh.mesh, PlaneMesh)):
			mesh.set_mesh(PlaneMesh.new())
			mesh.mesh.size.x = 10
			mesh.mesh.size.y = 10
		
