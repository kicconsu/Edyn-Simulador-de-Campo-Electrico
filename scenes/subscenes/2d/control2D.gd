extends Control
@onready var carga = $TabContainer/Charge_Editor/Carga
@onready var x = $TabContainer/Charge_Editor/X
@onready var y = $TabContainer/Charge_Editor/Y
@onready var z = $TabContainer/Charge_Editor/Z
@onready var w = $TabContainer/Charge_Editor/W

var object

func _process(delta):
	if Input.is_action_just_pressed("mb_right"):
		var charges = get_tree().get_nodes_in_group("2D_charges")
		object = null
		for c in charges:
			if c.picked:
				object =  c
				break
		set_parameters()
		print("Object: ", object)


func set_parameters():
	if object !=null:
		carga.disconnect("value_changed",_on_carga_value_changed)
		x.disconnect("value_changed",_on_x_value_changed)
		y.disconnect("value_changed",_on_y_value_changed)
		z.disconnect("value_changed",_on_z_value_changed)
		w.disconnect("value_changed",_on_w_value_changed)
		match object.type:
			#Carga puntual
			0:
				carga.visible = true
				x.visible = false
				y.visible = false
				z.visible = false
				w.visible = false
				carga.min_value = -100
				carga.max_value = 100
				carga.step = 0.5
			#Varilla
			1:
				carga.visible = true
				if !x.visible or !y.visible or !z.visible:
					x.visible = true
					y.visible = true
					z.visible = true
				w.visible = false
				carga.min_value = -10
				carga.max_value = 10
				carga.step = 0.1
				x.min_value = 100
				x.max_value = 800
				y.min_value = 0
				y.max_value = 360
				w.set_value_no_signal(1)
				
			#Disco
			2:
				carga.visible = true
				x.visible = false
				z.visible = false
				w.visible = false
				if !y.visible:
					y.visible = true
				carga.min_value = -0.5
				carga.max_value = 0.5
				carga.step = 0.00001
				y.min_value = 1
				y.max_value = 200
				y.step = 0.1
				x.set_value_no_signal(0) 
				
				
			#Placa
			4:
				carga.visible = true
				if !x.visible or !y.visible or !w.visible:
					x.visible = true
					y.visible = true
					z.visible = true
					w.visible = true
				carga.min_value = -0.05
				carga.max_value = 0.05
				carga.step = 0.00001
				x.min_value = 50
				x.max_value = 1000
				y.min_value = 50
				y.max_value = 1000
				w.min_value = 0
				w.max_value = 360
		carga.connect("value_changed",_on_carga_value_changed)
		x.connect("value_changed",_on_x_value_changed)
		y.connect("value_changed",_on_y_value_changed)
		z.connect("value_changed",_on_z_value_changed)
		w.connect("value_changed",_on_w_value_changed)
		carga.set_value_no_signal(object.char)
		x.set_value_no_signal(object.info[0])
		y.set_value_no_signal(object.info[1])
		z.set_value_no_signal(object.info[2])
		w.set_value_no_signal(object.info[3])
	else:
		carga.visible = false
		x.visible = false
		y.visible = false
		z.visible = false
		w.visible = false


func _on_carga_value_changed(value):
	if object != null:
		carga.label_2.text = str(value)
		object.char = value

func _on_x_value_changed(value):
	if object != null:
		x.label_2.text = str(value)
		object.info[0] = value

func _on_y_value_changed(value):
	if object != null:
		y.label_2.text = str(value)
		object.info[1] = value
		if object.type == 1:
			object.info[1] = deg_to_rad(value)

func _on_z_value_changed(value):
	if object != null:
		z.label_2.text = str(value)
		object.info[2] = value

func _on_w_value_changed(value):
	if object != null:
		w.label_2.text = str(value)
		if object.type == 4:
			object.info[3] = deg_to_rad(value)
		else:
			object.info[3] = value
