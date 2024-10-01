extends Node2D

@export var type:int = 0
@export var char:float = 5
var hovered:bool = false
var picked:bool = false
var relative:Vector2 = Vector2(0,0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered:
		self.picked = !self.picked
	if event is InputEventMouseMotion and picked:
		self.position += event.relative

func _on_mouse_entered() -> void:
	self.hovered = true


func _on_mouse_exited() -> void:
	self.hovered = false
	#self.picked = false
