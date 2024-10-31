extends "res://2d_charge_father.gd"


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and Global.playing:
		self.picked = !self.picked
	
	if event.is_action_pressed("mb_left") and picked:
		sliders_scene.object = self
		sliders_scene.set_parameters()
	
	
	
