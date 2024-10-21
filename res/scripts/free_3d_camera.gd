extends Node3D
@onready var camera_3d = $Camera3D
@onready var control = $"../Control"
@onready var animation = $TabMenu/Animation

var toggle : bool

func _ready():
	camera_3d.set_current(true)
	toggle = false

func _process(_delta):
	pass
	
func _input(event):
	
	if Input.is_action_just_pressed("TAB"):
		
		if !toggle:
			animation.play("upside")
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			toggle = !toggle
