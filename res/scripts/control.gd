extends CanvasLayer

@onready var object_cursor = get_node("/root/main/Editor_Object")
@onready var animation = $TabMenu/Animation
@onready var x = $Sliders/TabContainer/VBoxContainer/X
@onready var y = $Sliders/TabContainer/VBoxContainer/Y
@onready var z = $Sliders/TabContainer/VBoxContainer/Z
@onready var w = $Sliders/TabContainer/VBoxContainer/W
@onready var carga = $Sliders/TabContainer/VBoxContainer/carga

signal object_selected(obj)

var path_object
var object
var bool_object : bool
var toggle : bool

func _ready():
	toggle = true
	Global.playing= true
	carga.step = 0.01

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
	if Input.is_action_just_pressed("mb_left") and Global.playing and bool_object:
			object = get_node(path_object)
			emit_signal("object_selected", _on_object_selected(object))

func _on_object_selected(obj):
	match object.type:
		0:
			match_0()
		1:
			match_1()
		2: 
			match_2()
		3: 
			match_3()
		4: 
			match_4()
	

func match_0():
	carga.min_value = -8
	carga.max_value = 8
	x.editable = false
	y.editable = false
	z.editable = false
	w.editable = false
	initial_value_slider()

func match_1():
	x.editable = true
	y.editable = true
	z.editable = true
	w.editable = false
	carga.min_value = -0.001
	carga.max_value=10.0
	x.min_value = 1.0
	x.max_value = 700.0
	y.min_value = 0.0
	y.max_value = 360.0
	z.min_value = 1.0
	z.max_value = 10.0
	initial_value_slider()

func match_2():
	x.value = 0
	w.editable = true
	x.editable = false
	y.editable = true
	z.editable = true
	carga.min_value = -0.001
	carga.max_value=10.0
	y.min_value = 1
	y.max_value = 30
	z.min_value = 1
	z.max_value = 20
	w.min_value = 1
	w.max_value = 20
	initial_value_slider()

func match_3():
	x.editable = true
	w.editable = true
	y.editable = true
	z.editable = true
	carga.min_value = -0.001
	carga.max_value=10.0
	x.min_value = 1
	x.max_value = 10
	y.min_value = 1
	y.max_value = 30
	z.min_value = 1
	z.max_value = 20
	w.min_value = 1
	w.max_value = 20
	initial_value_slider()
	
func match_4():
	x.editable = true
	w.editable = true
	y.editable = true
	z.editable = true
	carga.min_value = -0.001
	carga.max_value=10.0
	carga.step =0.01
	x.min_value = 1
	x.max_value = 700
	y.min_value = 1
	y.max_value = 700
	z.min_value = 1
	z.max_value = 20
	w.min_value = 0
	w.max_value = 360
	initial_value_slider()

func initial_value_slider():
	carga.set_value(object.char)
	x.set_value(object.info[0])
	y.set_value(object.info[1])
	z.set_value(object.info[2])
	w.set_value(object.info[3])
	
#No permite que se colocen objetos detras del TabContainer
func _on_h_box_container_mouse_entered():
	object_cursor.can_place = false
	
func _on_h_box_container_mouse_exited():
	object_cursor.can_place = true

func _on_label_mouse_entered():
	object_cursor.can_place = false

func _on_label_mouse_exited():
	object_cursor.can_place = true

func _on_carga_value_changed(value):
	carga.label_2.text = str(value)
	if object!= null:
		object.char = value

func _on_x_value_changed(value):
	x.label_2.text = str(value)
	if object!= null:
		object.info[0] = value

func _on_y_value_changed(value):
	y.label_2.text = str(value)
	if object!= null:
		if object.type == 1:
			object.info[1] = deg_to_rad(value)
		else :
			object.info[1] = value

func _on_z_value_changed(value):
	z.label_2.text = str(value)
	if object!= null:
		object.info[2] = value

func _on_w_value_changed(value):
	w.label_2.text = str(value)
	if object!= null:
		if object.type == 4:
			object.info[3] =deg_to_rad(value)
		else:
			object.info[3] = value
