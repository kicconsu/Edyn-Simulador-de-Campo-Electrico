extends Node3D
@onready var camera_3d = $Camera3D
@onready var control = $"../Control"


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.set_current(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
