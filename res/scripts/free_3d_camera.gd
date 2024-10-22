extends Node3D

@onready var camera_3d = $Camera3D
@onready var animation = $TabMenu/Animation

@onready var interaction = $Camera3D/Interaction
@onready var hand = $Camera3D/Hand

var picked_object
var pull_power = 4

var toggle : bool

func _ready():
	camera_3d.set_current(true)
	toggle = false

func pick_object():
	var collider = interaction.get_collider()
	
	if collider != null and collider.is_in_group("3D_charges"):
		print("A")
		
	
func _input(event):
	
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			animation.play("upside")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
			toggle = !toggle

func _on_button_pressed():
	animation.play_backwards("upside")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	toggle = false
