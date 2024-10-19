extends CanvasLayer

@onready var object_cursor = get_node("/root/main/Editor_Object")

func _process(delta):
	if Input.is_action_just_pressed("toggle_editor"):
		Global.playing = !Global.playing
		visible = !Global.playing

#No permite que se colocen objetos detras del TabContainer
func _on_h_box_container_mouse_entered():
	object_cursor.can_place = false
	
func _on_h_box_container_mouse_exited():
	object_cursor.can_place = true

func _on_cuerpos_2d_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
func _on_cuerpos_2d_mouse_exited():
	object_cursor.can_place = true
	object_cursor.hide()
