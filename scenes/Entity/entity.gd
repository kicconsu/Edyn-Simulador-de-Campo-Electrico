extends Area2D

var hovered:bool = false
var picked:bool = false
var angle =0
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and Global.playing:
		self.picked = !self.picked
	if event is InputEventMouseMotion and picked:
		self.position = get_global_mouse_position()
	if picked and event.is_action_pressed("rotate") :
		angle += 15
		if angle == 360:
			angle = 0
		rotate_angle(angle)

func rotate_angle(ang : int):
	rotation_degrees = ang
	
func _on_mouse_entered() -> void:
	print("entró el moues")
	self.hovered = true

func _on_mouse_exited() -> void:
	print("salio el mouse")
	self.hovered = false
