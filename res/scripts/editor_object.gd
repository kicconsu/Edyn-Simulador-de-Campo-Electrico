extends Node2D

#@onready var level = $"../Level"
@onready var editor = get_node("/root/2dTest/Node2D/cam_container")
@onready var editor_cam = editor.get_node("Camera2D")

var cam_spd = 10
var current_item:PackedScene
var can_place
var is_panning


# Called when the node enters the scene tree for the first time.
func _ready():
	editor_cam.make_current()
	can_place = true
	is_panning = true
	
func _process(_delta):
	
	self.global_position = get_global_mouse_position()
	
	#Al existir un current item en mano, instanciarlo inmediatamente
	if current_item != null:
		pass
		var new_item = current_item.instantiate()
		#level.add_child(new_item)
		self.get_parent().get_parent().add_child(new_item)
		new_item.picked = true
	
	move_editor()
	is_panning = Input.is_action_pressed("mb_middle")
	
func move_editor():
	if Input.is_action_pressed("W"):
		editor.global_position.y -= cam_spd
	if Input.is_action_pressed("A"):
		editor.global_position.x -= cam_spd
	if Input.is_action_pressed("S"):
		editor.global_position.y += cam_spd
	if Input.is_action_pressed("D"):
		editor.global_position.x += cam_spd

func _unhandled_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed()):
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
				editor_cam.zoom += Vector2(0.1,0.1)
			if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN) and editor_cam.zoom != Vector2(0,0):
				editor_cam.zoom -= Vector2(0.1,0.1)
		editor_cam.zoom = clamp(editor_cam.zoom, Vector2(0.3, 0.3), Vector2(15.0, 15.0))
	if(event is InputEventMouseMotion):
		if(is_panning):
			editor.global_position -= event.relative * editor_cam.zoom
