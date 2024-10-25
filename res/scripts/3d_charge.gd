@tool
extends Node3D

@export var type:int = 0
@export var char:float = 1
@export var radius:float = 2
@export_range(16, 255) var transparency:int = 255
@onready var mesh:CSGMesh3D = $CSGMesh3D

func _ready() -> void:
	self.mesh.material = self.mesh.material.duplicate(true)
	$CSGMesh3D.material_overlay = $CSGMesh3D.material_overlay.duplicate(true)

func _process(_delta: float) -> void:
	
	if(self.char > 0):
		self.mesh.material.albedo_color = '#ff2165' + ('%x' % self.transparency)
	else:
		self.mesh.material.albedo_color = '#5087ff' + ('%x' % self.transparency)
		
	if(self.type == 0):
		if(not is_instance_of(mesh.mesh, SphereMesh)):
			mesh.set_mesh(SphereMesh.new())
			mesh.mesh.radial_segments = 10
			mesh.mesh.rings = 5
			mesh.material.set_cull_mode(0)
		mesh.mesh.radius = 0.3
		mesh.mesh.height = 0.3*2
	elif(self.type == 1):
		if(not is_instance_of(mesh.mesh, SphereMesh)):
			mesh.set_mesh(SphereMesh.new())
			mesh.mesh.radial_segments = 10
			mesh.mesh.rings = 5
			mesh.material.set_cull_mode(0)
		mesh.mesh.radius = self.radius
		mesh.mesh.height = mesh.mesh.radius*2
	elif(self.type == 2):
		if(not is_instance_of(mesh.mesh, CylinderMesh)):
			mesh.set_mesh(CylinderMesh.new())
			mesh.mesh.height = 1000
			mesh.mesh.cap_top = false
			mesh.mesh.cap_bottom = false
			mesh.mesh.radial_segments = 5
			mesh.material.set_cull_mode(0)
		mesh.mesh.top_radius = 0.1
		mesh.mesh.bottom_radius = 0.1
	elif(self.type == 3):
		if(not is_instance_of(mesh.mesh, CylinderMesh)):
			mesh.set_mesh(CylinderMesh.new())
			mesh.mesh.height = 1000
			mesh.mesh.cap_top = false
			mesh.mesh.cap_bottom = false
			mesh.mesh.radial_segments = 5
			mesh.material.set_cull_mode(0)
		mesh.mesh.top_radius = self.radius*3
		mesh.mesh.bottom_radius = self.radius*3
	elif(self.type == 4):
		if(not is_instance_of(mesh.mesh, PlaneMesh)):
			mesh.set_mesh(PlaneMesh.new())
			mesh.mesh.size.x = 5
			mesh.mesh.size.y = 5
			mesh.material.set_cull_mode(2)

func set_property(tag: String, value: float):
	match tag:
		"radius":
			self.radius = value
		"char":
			self.char = value

func get_config_seed() -> Dictionary:
	
	const DISTANCE_UNITS = "m"
	const CHARGE_UNITS = "C"
	
	var config: Dictionary = {}
	match self.type:
		0:
			config =  {
				"name": "Carga Puntual",
				"adjustments": [
					{
						"name": "Carga (Q)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -100,
						"max": 100,
						"units": CHARGE_UNITS
					},
					{
						"name": "Posición",
						"type": "array",
						"editable": false,
						"values": [
							{
								"label": "X",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Y",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Z",
								"units": DISTANCE_UNITS,
							}
						]
					},
				]
			}
		1:
			config = {
				"name": "Esfera Uniforme",
				"adjustments": [
					{
						"name": "Radio (R)",
						"type": "slider",
						"tag": "radius",
						"value": self.radius,
						"min": 0,
						"max": 100,
						"units": DISTANCE_UNITS
					},
					{
						"name": "Densidad de Carga (ρ)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -100,
						"max": 100,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS+"^3",
					},
					{
						"name": "Posición",
						"type": "array",
						"editable": false,
						"values": [
							{
								"label": "X",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Y",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Z",
								"units": DISTANCE_UNITS,
							}
						]
					},
					
				]
			}
		2:
			config = {
				"name": "Varilla Infinita",
				"adjustments": [
					{
						"name": "Densidad de Carga (λ)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -100,
						"max": 100,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Posición",
						"type": "array",
						"editable": false,
						"values": [
							{
								"label": "X",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Y",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Z",
								"units": DISTANCE_UNITS,
							}
						]
					},
					{
						"name": "Rotación",
						"type": "array",
						"editable": true,
						"values": [
							{
								"label": "X",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Y",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Z",
								"min": -360,
								"max": 360,
								"units": "°",
							}
						]
					}
				]
			}
		3:
			config = {
				"name": "Cilindro Infinito",
				"adjustments": [
					{
						"name": "Densidad de Carga (ρ)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -100,
						"max": 100,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Radio (R)",
						"type": "slider",
						"tag": "radius",
						"value": self.radius,
						"min": "100",
						"max": 100,
						"units": DISTANCE_UNITS,
					},
					{
						"name": "Posición",
						"type": "array",
						"editable": false,
						"values": [
							{
								"label": "X",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Y",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Z",
								"units": DISTANCE_UNITS,
							}
						]
					},
					{
						"name": "Rotación",
						"type": "array",
						"editable": true,
						"values": [
							{
								"label": "X",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Y",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Z",
								"min": -360,
								"max": 360,
								"units": "°",
							}
						]
					}
				]
			}
		4:
			config = {
				"name": "Placa Infinita",
				"adjustments": [
					{
						"name": "Densidad de Carga (σ)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -100,
						"max": 100,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Posición",
						"type": "array",
						"editable": false,
						"values": [
							{
								"label": "X",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Y",
								"units": DISTANCE_UNITS,
							},
							{
								"label": "Z",
								"units": DISTANCE_UNITS,
							}
						]
					},
					{
						"name": "Rotación",
						"type": "array",
						"editable": true,
						"values": [
							{
								"label": "X",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Y",
								"min": -360,
								"max": 360,
								"units": "°",
							},
							{
								"label": "Z",
								"min": -360,
								"max": 360,
								"units": "°",
							}
						]
					}
				]
			}
	return config
