class_name FreeLookCamera extends Camera3D
# Simple free look camera script
# Sacado de https://github.com/adamviola/simple-free-look-camera
# Adaptado para godot 4
# 2023 Enero last update

# Modificar vel multiplier
# Usar W A S D
# Mantener presionado click derecho 
# Con shift vas mas rapido
# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

signal ray_casted(body)

@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
var dragging = false
var rotating

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 12.5
var _deceleration = -10
@export var _vel_multiplier = 10

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

var selected : CSGMesh3D
const RAY_LENGTH = 1000
func cam_raycast(towards:Vector2) -> CSGMesh3D:
	var cam = get_viewport().get_camera_3d()
	
	var from = cam.project_ray_origin(towards)
	var to = from + cam.project_ray_normal(towards)*RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	
	return get_world_3d().direct_space_state.intersect_ray(query).get("collider")

func select_body(body: CSGMesh3D):
	if selected != body:
		if selected != null:
			selected.material_overlay.grow_amount = 0
			if body == null:
				ray_casted.emit(false)
		else:
			ray_casted.emit(true)
	
	selected = body
	if selected == null:
		return
	
	selected.material_overlay.grow_amount = 0.05

func _unhandled_input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		
		
		if dragging and selected:
			var charge = selected.get_parent()
			if rotating:
				#Update rotation
				const rotation_speed = 0.2
				var mouse_delta = event.relative
				charge.rotation_degrees.y -= mouse_delta.x * rotation_speed
				charge.rotation_degrees.x -= mouse_delta.y * rotation_speed
				$"../CanvasLayer".update_custom_array("rotation", charge.rotation_degrees)
			else:
				#Update position
				var mousepos = get_viewport().get_mouse_position()
				var  cam = get_viewport().get_camera_3d()
				var origin = cam.project_ray_origin(mousepos)
				var end = cam.project_ray_normal(mousepos)
				var depth = origin.distance_to(charge.global_position)
				var final_position = origin + end * depth
				charge.global_position = final_position
				$"../CanvasLayer".update_custom_array("position", charge.global_position)
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, _vel_multiplier*20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, _vel_multiplier*20)
		
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if event.pressed:
						var body = cam_raycast(get_viewport().get_mouse_position())
						select_body(body)
						dragging = body != null
					else:
						dragging = false

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed
			KEY_R:
				if event.pressed and dragging:
					rotating = true
				else:
					rotating = false

# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float),
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))


func _on_remove_body_pressed() -> void:
	selected.get_parent().queue_free()
	select_body(null)
