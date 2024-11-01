extends Control

@onready var carga = $TabContainer/ScrollContainer/VBoxContainer/Carga
@onready var x = $TabContainer/ScrollContainer/VBoxContainer/X
@onready var y = $TabContainer/ScrollContainer/VBoxContainer/Y
@onready var z = $TabContainer/ScrollContainer/VBoxContainer/Z
@onready var w = $TabContainer/ScrollContainer/VBoxContainer/W

var object

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
				x.visible = false
				y.visible = false
				z.visible = false
				w.visible = false
				carga.min_value = -10
				carga.max_value = 10
				carga.step = 1
			#Varilla
			1:
				if !x.visible or !y.visible or !z.visible:
					x.visible = true
					y.visible = true
					z.visible = true
				w.visible = false
				carga.min_value = 0
				carga.max_value = 10
				carga.step = 0.1
				x.min_value = 100
				x.max_value = 800
				y.min_value =0
				y.max_value = 360
				w.set_value_no_signal(1)
				
			#Disco
			2:
				x.visible = false
				z.visible = false
				w.visible = false
				if !y.visible:
					y.visible = true
				carga.min_value = -10
				carga.max_value = 10
				carga.step = 0.1
				y.min_value = 1
				y.max_value = 10
				x.set_value_no_signal(0) 
				
			#Anillo
			3:
				z.visible = false
				w.visible = false
				if !y.visible or !x.visible:
					y.visible = true
					x.visible = true
				carga.min_value = -10
				carga.max_value = 10
				carga.step = 0.1
				x.min_value = 0
				x.max_value = 10
				x.step = 0.5
				y.min_value = 1
				y.max_value = 10
				x.step = 0.5
				z.set_value_no_signal(9)
				w.set_value_no_signal(1)
				
				
			#Placa
			4:
				z.visible = false
				if !x.visible or !y.visible or !w.visible:
					x.visible = true
					y.visible = true
					w.visible = true
				carga.min_value = -0.001
				carga.max_value = 1
				carga.step = 0.001
				x.min_value = 200
				x.max_value =600
				y.min_value = 1
				y.max_value =300
				w.min_value = 0
				w.max_value = 360
		carga.connect("value_changed",_on_carga_value_changed)
		x.connect("value_changed",_on_x_value_changed)
		y.connect("value_changed",_on_y_value_changed)
		z.connect("value_changed",_on_z_value_changed)
		w.connect("value_changed",_on_w_value_changed)
		carga.set_value(object.char)
		x.set_value(object.info[0])
		y.set_value(object.info[1])
		z.set_value(object.info[2])
		w.set_value(object.info[3])
		
		
					

func _on_carga_value_changed(value):
	if object != null:
		carga.label_2.text = str(value)
		object.char = value
		object.change_sprite(value)

func _on_x_value_changed(value):
	if object != null:
		x.label_2.text = str(value)
		object.info[0] = value
		if object.type ==1:
			object.collision_shape.shape.extents = Vector2(value, 10)
		if object.type == 4:
			object.sprite_2d.scale = Vector2(x.value*0.0045, y.value*0.02)
			object.collision_shape.shape.extents = Vector2(x.value/2, y.value/4)

func _on_y_value_changed(value):
	if object != null:
		y.label_2.text = str(value)
		match object.type:
			1:
				print("rotating to: ", value)
				object.info[1] = deg_to_rad(value)
			2:
				object.collision_shape.shape.radius = value*8
				object.sprite_2d.scale = Vector2(value*0.1, value*0.1)
			3:
				object.collision_shape.shape.radius = value*10
				object.sprite_2d.scale = Vector2(value*0.14, value*0.14)
			4:
				object.sprite_2d.scale = Vector2(x.value*0.0045, y.value*0.02)
				object.collision_shape.shape.extents = Vector2(x.value/2, y.value/4)
				object.info[1] = value

func _on_z_value_changed(value):
	if object != null:
		z.label_2.text = str(value)
		object.info[2] = value

func _on_w_value_changed(value):
	if object != null:
		w.label_2.text = str(value)
		if object.type == 4:
			object.info[3] = deg_to_rad(value)
			object.rotation = deg_to_rad(value)
		else:
			object.info[3] = value
