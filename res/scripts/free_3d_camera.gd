extends Node3D

@onready var camera_3d = $Camera3D
@onready var animation = $CanvasLayer/TabMenu/Animation
@onready var projection = $Camera3D/Projection

var picked_object
var pull_power = 4

var toggle : bool
var changeProjection = false

func _ready():
	camera_3d.set_current(true)
	toggle = false
	
func _input(event):
	
	if Input.is_action_just_pressed("changeProjection"):
		if changeProjection:
			projection.play_backwards("changeProjection")
			changeProjection = !changeProjection
		else:
			projection.play("changeProjection")
			changeProjection = !changeProjection
	
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			animation.play("upside")
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			toggle = !toggle

func _on_button_pressed():
	animation.play_backwards("upside")
	toggle = false
