extends CanvasLayer

@onready var object_cursor = get_node("/root/2dTest/Node2D/Editor_Object")
@onready var animation = $TabMenu/Animation

var bool_object : bool
var toggle : bool

func _ready():
	toggle = true
	Global.playing= true

func _input(event):
	if Input.is_action_just_pressed("TAB"):
		if toggle:
			animation.play("upside")
			object_cursor.can_place = !object_cursor.can_place
			Global.playing = !Global.playing
			toggle = !toggle
		else:
			animation.play_backwards("upside")
			object_cursor.can_place = !object_cursor.can_place
			Global.playing = !Global.playing
			toggle = !toggle
	
#No permite que se colocen objetos detras del TabContainer
func _on_h_box_container_mouse_entered():
	object_cursor.can_place = false
	
func _on_h_box_container_mouse_exited():
	object_cursor.can_place = true

func _on_label_mouse_entered():
	object_cursor.can_place = false

func _on_label_mouse_exited():
	object_cursor.can_place = true
