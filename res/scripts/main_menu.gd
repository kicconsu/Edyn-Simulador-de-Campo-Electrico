extends Control

@onready var anim = $AnimationPlayer
var play_scene = preload("res://scenes/main_menu/play_menu.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("glow")


func _on_play_pressed():
	var play = play_scene.instantiate() 
	play.position = Vector2(0,0)	
	add_child(play)
