extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)
const k: float = 9*pow(10,9)
var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not hovered:
		self.picked = false
	if event is InputEventMouseButton and hovered:
		self.picked = !self.picked
	if event is InputEventMouseMotion and picked:
		self.position += event.relative

func _on_mouse_entered() -> void:
	self.hovered = true


func _on_mouse_exited() -> void:
	self.hovered = false
	#self.picked = false


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
