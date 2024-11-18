extends "res://res/scripts/2d_charge_father.gd"


func _on_mouse_entered() -> void:
	print("Mouse entered")
	pass
	self.hovered = true
	
func _on_mouse_exited() -> void:
	print("Mouse exited")
	pass
	self.hovered = false
