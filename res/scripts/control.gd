extends Control

@onready var object_cursor = get_node("/root/main/Editor_Object")

#No permite que se colocen objetos detras del TabContainer
func _on_h_box_container_mouse_entered():
	object_cursor.can_place = false

func _on_h_box_container_mouse_exited():
	object_cursor.can_place = true

func _on_cuerpos_2d_mouse_entered():
	object_cursor.can_place = false
	
func _on_cuerpos_2d_mouse_exited():
	object_cursor.can_place = true
