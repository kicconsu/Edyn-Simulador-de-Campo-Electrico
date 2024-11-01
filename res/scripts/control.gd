extends CanvasLayer

@onready var object_cursor = get_node("/root/2dTest/Node2D/Editor_Object")
@onready var animation = $TabMenu/Animation

var bool_object : bool
var toggle : bool
var picked : Node

func _ready():
	toggle = true
	Global.playing = true

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

#Coloca la carga correspondiente en el cursor.
func _on_puntual_pressed() -> void:
	var charg:PackedScene = load("res://scenes/subscenes/2d/2d_charge.tscn")
	var chargeNode:Node = charg.instantiate()
	chargeNode.type = 0
	chargeNode.picked = true
	self.get_parent().add_child(chargeNode)


func _on_line_pressed() -> void:
	var charg:PackedScene = load("res://scenes/subscenes/2d/2d_charge.tscn")
	var chargeNode:Node = charg.instantiate()
	chargeNode.type = 1
	chargeNode.info = Vector4(300, 0, 7, -1)
	self.get_parent().add_child(chargeNode)


func _on_disk_pressed() -> void:
	var charg:PackedScene = load("res://scenes/subscenes/2d/2d_charge.tscn")
	var chargeNode:Node = charg.instantiate()
	chargeNode.type = 2
	chargeNode.char = 0.005
	chargeNode.info = Vector4(0, 20, 5, 5)
	self.get_parent().add_child(chargeNode)


func _on_plane_pressed() -> void:
	var charg:PackedScene = load("res://scenes/subscenes/2d/2d_charge.tscn")
	var chargeNode:Node = charg.instantiate()
	chargeNode.type = 4
	chargeNode.char = 0.0005
	chargeNode.info = Vector4(150, 100, 5, 0)
	self.get_parent().add_child(chargeNode)


func _on_lupa_pressed():
	var charg:PackedScene = load("res://scenes/subscenes/2d/2d_charge.tscn")
	var chargeNode:Node = charg.instantiate()
	chargeNode.type = 5
	chargeNode.char = 0
	self.get_parent().add_child(chargeNode)
