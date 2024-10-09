extends TabContainer

@onready var object_cursor = get_node("/root/main/Editor_Object")

func _on_mouse_entered():
	object_cursor.can_place = false

func _on_mouse_exited():
	object_cursor.can_place = true
