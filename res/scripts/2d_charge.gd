extends Node2D

@export var type:int = 0
@export var char:float = 5
@export var info:= Vector4(1, 1, 1, 1)
var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)

func _ready():
	match type:
		2:
			$CollisionShape2D.set_shape(CircleShape2D.new())
		4:
			$CollisionShape2D.set_shape(RectangleShape2D.new())

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
