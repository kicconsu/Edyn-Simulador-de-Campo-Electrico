extends Node2D

var can_place
@onready var level = $"../Level"

var current_item 

# Called when the node enters the scene tree for the first time.
func _ready():
	can_place = true
	
func _process(_delta):
	
	global_position = get_global_mouse_position()
	#Se añade un nuevo objeto cada que se hace click
	if current_item != null and can_place and Input.is_action_just_pressed("mb_left"):
		var new_item = current_item.instantiate()
		level.add_child(new_item)
		new_item.global_position = get_global_mouse_position()
		 
