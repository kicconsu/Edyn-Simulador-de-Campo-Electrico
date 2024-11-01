#@tool
extends Node3D

@export var type:int = 0
@export var char:float = 1
@export var radius:float = 2
@export_range(16, 255) var transparency:int = 255
@onready var mesh:CSGMesh3D = $CSGMesh3D

const k: float = 9*pow(10,9)
const e_0: float = 8.85*pow(10,-12)
var field: Vector3 = Vector3.ZERO

func _ready() -> void:
	self.mesh.mesh = self.mesh.mesh.duplicate(true)
	self.mesh.material = self.mesh.material.duplicate(true)
	$CSGMesh3D.material_overlay = $CSGMesh3D.material_overlay.duplicate(true)
	
func _process(_delta: float) -> void:
	
	if self.type < 5:
		if(self.char > 0):
			self.mesh.material.albedo_color = '#ff2165' + ('%x' % self.transparency)
		else:
			self.mesh.material.albedo_color = '#5087ff' + ('%x' % self.transparency)
	else:
		self.mesh.material.albedo_color = Color(0,255,0)
		
	match self.type:
		0:
			if(not is_instance_of(mesh.mesh, SphereMesh)):
				mesh.set_mesh(SphereMesh.new())
				mesh.mesh.radial_segments = 10
				mesh.mesh.rings = 5
				mesh.material.set_cull_mode(0)
			mesh.mesh.radius = 0.3
			mesh.mesh.height = 0.3*2
		1:
			if(not is_instance_of(mesh.mesh, SphereMesh)):
				mesh.set_mesh(SphereMesh.new())
				mesh.mesh.radial_segments = 10
				mesh.mesh.rings = 5
				mesh.material.set_cull_mode(0)
			mesh.mesh.radius = self.radius
			mesh.mesh.height = mesh.mesh.radius*2
		2:
			if(not is_instance_of(mesh.mesh, CylinderMesh)):
				mesh.set_mesh(CylinderMesh.new())
				mesh.mesh.height = 1000
				mesh.mesh.cap_top = false
				mesh.mesh.cap_bottom = false
				mesh.mesh.radial_segments = 5
				mesh.material.set_cull_mode(0)
			mesh.mesh.top_radius = 0.1
			mesh.mesh.bottom_radius = 0.1
		3:
			if(not is_instance_of(mesh.mesh, CylinderMesh)):
				mesh.set_mesh(CylinderMesh.new())
				mesh.mesh.height = 1000
				mesh.mesh.cap_top = false
				mesh.mesh.cap_bottom = false
				mesh.mesh.radial_segments = 5
				mesh.material.set_cull_mode(0)
			mesh.mesh.top_radius = self.radius
			mesh.mesh.bottom_radius = self.radius
		4:
			if(not is_instance_of(mesh.mesh, PlaneMesh)):
				mesh.set_mesh(PlaneMesh.new())
				mesh.mesh.size.x = 5
				mesh.mesh.size.y = 5
				mesh.material.set_cull_mode(2)
		5:
			if(not is_instance_of(mesh.mesh, SphereMesh)):
				mesh.set_mesh(SphereMesh.new())
				mesh.mesh.radial_segments = 10
				mesh.mesh.rings = 5
				mesh.material.set_cull_mode(0)
			mesh.mesh.radius = 0.05
			mesh.mesh.height = 0.05*2
			#Calculate veccamp at current pos
			var charges = get_tree().get_nodes_in_group("3D_charges")
			field = Vector3.ZERO
			for c in charges:
				field += c.calculateElectricField(self.global_position)
			#print("Campo electrico de la carga de prueba: ",field)
			

#Triggered when a custom_slider/custom_array value is correctly modified: updates the body's desired property
func set_property(tag: String, value):
	match tag:
		"radius":
			self.radius = value
		"transp":
			self.transparency = value
		"char":
			self.char = value
		"position":
			#Not editable through direct user input: value's already passed correctly
			self.global_position = value
		"rotation":
			#value's a Vector3 where only the rotated axis component is different than zero, so we need to find out which one it is 
			#TODO: this and the custom sliders/arrays need to be done in a clearer way
			if value is Vector3:
				if value.x != 0:
					self.rotation_degrees = Vector3(value.x, self.rotation.y, self.rotation.z)
				if value.y != 0:
					self.rotation_degrees = Vector3(self.rotation.x, value.y, self.rotation.z)
				if value.z != 0:
					self.rotation_degrees = Vector3(self.rotation.x, self.rotation.y, value.z)
		

func calculateElectricField(pos):
	match self.type:
		0: # Carga puntual
			return pointCharge(pos)
		1: # Esfera cargada
			return chargedSphere(pos)
		2: # Varilla infinita
			return infiniteLine(pos)
		3: # Cilindro infinito
			return infiniteCylinder(pos)
		4: # Placa Infinita
			return infinitePlane(pos)
		5: 
			return Vector3.ZERO
			
func pointCharge(pos):
	var charge = self.char*pow(10,-10)
	var r: Vector3 = pos - self.global_position 
	var dist: float = r.length()
			
	if dist == 0:
		return Vector3.ZERO
			
	var dir: Vector3 = r.normalized()
	var mag: float = (k*charge/(dist*dist))
			
	return dir*mag

func infinitePlane(pos):
	var charge = self.char*pow(10,-9)
	var r: Vector3 = pos - self.global_position 
	var n := Vector3(self.global_basis.y.x,self.global_basis.y.y,self.global_basis.y.z)
	var d: float = r.dot(n)
			
	if abs(d) < 1e-6:
		return Vector3.ZERO
			
	var field = charge / (2*e_0)
			
	# Direccion del campo
			
	if d > 0:
		return field*n
	else:
		return -field*n
			
			
func infiniteCylinder(pos):
	var charge = self.char*pow(10,-9)
	var v: Vector3 = pos - self.global_position 
	var d := Vector3(self.global_basis.y.x,self.global_basis.y.y,self.global_basis.y.z)
	var proj:= v.dot(d)*d
			
	#Distancia Radial
	var dist: Vector3 = v - proj
	var dir = dist.normalized()
	var r = dist.length()
	var R: float = self.radius
			
	if r < R:
		return (charge * r) / (2.0 * e_0) * dir
	else:
		return (charge * R * R) / (2.0 * e_0 * r) * dir

func infiniteLine(pos):
	var charge = self.char*pow(10,-9)
	var v: Vector3 = pos - self.global_position 
	var d := Vector3(self.global_basis.y.x,self.global_basis.y.y,self.global_basis.y.z)
	var proj = v.dot(d)*d
			
			#Distancia Radial
	var dist = v -proj
	var r = dist.length()
			
	var field = 2*k*charge/r
	return field*dist.normalized()

func chargedSphere(pos):
	var charge = self.char*pow(10,-9)
	var r: Vector3 = pos - self.global_position 
	var dist: float = r.length()
	var R: float = self.radius
			
	if dist < R:
		return k*charge*dist/(R*R*R)*r.normalized()
	
	return pointCharge(pos)
				
func get_config_seed() -> Dictionary:
	
	const DISTANCE_UNITS = "m"
	const CHARGE_UNITS = "*0.1 nC"
	
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
						"min": -50,
						"max": 50,
						"step": 0.1,
						"units": CHARGE_UNITS
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"max": 5,
						"step": 0.1,
						"units": DISTANCE_UNITS
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					{
						"name": "Densidad de Carga (ρ)",
						"type": "slider",
						"tag": "char",
						"value": self.char,
						"min": -50,
						"max": 50,
						"step": 0.01,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS+"^3",
					},
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"min": -50,
						"max": 50,
						"step": 0.01,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"tag": "rotation",
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
						"min": -50,
						"max": 50,
						"step": 0.01,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					{
						"name": "Radio (R)",
						"type": "slider",
						"tag": "radius",
						"value": self.radius,
						"min": 0,
						"max": 1,
						"step": 0.1,
						"units": DISTANCE_UNITS,
					},
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"tag": "rotation",
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
						"min": -50,
						"max": 50,
						"step": 0.01,
						"units": CHARGE_UNITS+"/"+DISTANCE_UNITS,
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"tag": "rotation",
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
		5:
			config = {
				"name": "Carga de prueba",
				"adjustments": [
					{
						"name": "Posición",
						"type": "array",
						"tag": "position",
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
						"name": "Campo Eléctrico",
						"type": "array",
						"tag": "field",
						"editable": false,
						"values": [
							{
								"label": "i",
								"units": "N/"+CHARGE_UNITS,
							},
							{
								"label": "j",
								"units": "N/"+CHARGE_UNITS,
							},
							{
								"label": "k",
								"units": "N/"+CHARGE_UNITS,
							}
						]
					},
					{
						"name": "Transparencia",
						"type": "slider",
						"tag": "transp",
						"value": self.transparency,
						"min": 16,
						"max": 255,
						"step": 0.1,
						"units": "",
					},
					
				]
			}
	return config
