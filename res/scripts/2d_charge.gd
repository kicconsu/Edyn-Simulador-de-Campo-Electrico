extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)
@onready var sprite_2d = $Sprite2D

@onready var sliders_scene = get_node("/root/2dTest/Node2D/Control")

var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)
var angle = 0
var once = true


func _process(_delta):
	
	match self.type:
		0:
			if self.char >=0:
				$Sprite2D.texture = preload("res://res/img/carga1.png")
			else:
				$Sprite2D.texture = preload("res://res/img/carga2.png")
		1:
			$Sprite2D.position= Vector2(self.info[0]/2, 0)
			if self.char >=0:
				$Sprite2D.texture = preload("res://res/img/varPos.png")
			else:
				$Sprite2D.texture = preload("res://res/img/varNeg.png")
		2: 
			if self.char >=0:
				$Sprite2D.texture = preload("res://res/img/esfPos.png")
			else:
				$Sprite2D.texture = preload("res://res/img/esfNeg.png")
		3: 
			if self.char >= 0:
				$Sprite2D.texture = preload("res://res/img/anilPos.png")
			else:
				$Sprite2D.texture = preload("res://res/img/anisNeg.png")
		4: 
			if self.char >=0:
				$Sprite2D.texture = preload("res://res/img/placaPos.png")
			else:
				$Sprite2D.texture = preload("res://res/img/placaNeg.png")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and Global.playing:
		self.picked = !self.picked
	
	if event.is_action_pressed("mb_left") and picked:
		sliders_scene.object = self
		sliders_scene.set_parameters()
			
	if event is InputEventMouseMotion and picked:
			self.position = get_global_mouse_position()


func _on_mouse_entered() -> void:
	self.hovered = true
	
func _on_mouse_exited() -> void:
	self.hovered = false
