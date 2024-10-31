extends "res://2d_charge_father.gd"


func _input(event: InputEvent) -> void:
	
	super._input(event)

	if event is InputEventMouseMotion and picked:
			self.position = get_global_mouse_position()
