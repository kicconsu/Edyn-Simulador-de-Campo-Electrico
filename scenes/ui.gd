extends Control

var picked_object
var pull_power = 4

var toggle : bool = false

func _input(event):
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			$Animation.play("upside")
			toggle = !toggle
		else:
			$Animation.play_backwards("upside")
			toggle = !toggle

func _on_button_pressed():
	$Animation.play_backwards("upside")
	toggle = false
