extends Control

@onready var anim = $AnimationPlayer
@onready var button_2d = $"CanvasLayer/2d"
@onready var button_3d = $"CanvasLayer/3d"

var exit: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("intro")
	exit = false

func _on_button2d_pressed():
	anim.play_backwards("intro")
	exit = true
	
func _on_button3d_pressed():
	anim.play_backwards("intro")
	exit = true
	
func _on_exit_pressed():
	anim.play_backwards("intro")
	exit = true
	

func _on_animation_player_animation_finished(intro):
	if exit:
		queue_free()
