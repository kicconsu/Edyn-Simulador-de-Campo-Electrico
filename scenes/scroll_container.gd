extends ScrollContainer

@onready var object_cursor = get_node("/root/main/Editor_Object") 
func _ready():
	connect("mouse_entered", Callable(self, "mouse_enter"))
	connect("mouse_exited",Callable(self,"mouse_leave")) 
	
func mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	pass

func mouse_leave():
	object_cursor.can_place = true
	object_cursor.show()
	
	pass
