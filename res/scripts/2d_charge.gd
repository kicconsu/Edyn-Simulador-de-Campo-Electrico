extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)

@onready var scene = get_node("/root/main/Item_Select")

var char_slider

var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)
var angle = 0
	

func _process(_delta):
	match self.type:
		1:
			$Sprite2D.texture = preload("res://res/img/varilla.png")
		2: 
			$Sprite2D.texture = preload("res://res/img/disco.png")
		3: 
			$Sprite2D.texture = preload("res://res/img/anillo.png")
		4: 
			$Sprite2D.texture = preload("res://res/img/placa.png")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and Global.playing:
		scene.path_object = self.get_path()
		scene.bool_object = true 
		self.picked = !self.picked
	if event is InputEventMouseMotion and picked:
			self.position = get_global_mouse_position()
	if picked and event.is_action_pressed("rotate") :
		angle += 15
		if angle == 360:
			angle = 0
		rotate_angle(angle)
		if  type == 1:
			info.y = deg_to_rad(angle)
		if type == 4:
			info.w = deg_to_rad(angle)
		
func rotate_angle(ang : int):
	rotation_degrees = ang

func _on_mouse_entered() -> void:
	self.hovered = true
	
func _on_mouse_exited() -> void:
	self.hovered = false
