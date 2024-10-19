extends Area2D

var hovered:bool = false
var picked:bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and Global.playing:
		self.picked = !self.picked
	if event is InputEventMouseMotion and picked :
		self.position = get_global_mouse_position()

func _on_mouse_entered() -> void:
	self.hovered = true

func _on_mouse_exited() -> void:
	self.hovered = false
	#self.picked = false
