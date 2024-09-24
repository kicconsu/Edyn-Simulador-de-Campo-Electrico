extends Node2D

@export var res:int = 25
@export var size:Vector2 = Vector2(1000.0, 500.0)
@onready var vec_scene:PackedScene = load("res://scenes/subscenes/2d_arrow.tscn")

func _ready():
	#Instantiate vectors to populate vector camp
	var vec_interval:Vector2 = Vector2(size.x/res, size.y/(res/2))
	for i in range(int(res/2)):
		for j in range(res):
			var vec = vec_scene.instantiate()
			add_child(vec)
			vec.set_position(Vector2(vec_interval.x*j, vec_interval.y*i)-size/2+size/50)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
