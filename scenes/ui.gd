extends Control

@onready var animation = $TabMenu/Animation

var toggle : bool = false
	
func _input(event):
	
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			animation.play("upside")
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			toggle = !toggle
