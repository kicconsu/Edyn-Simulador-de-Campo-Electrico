extends CanvasLayer

const CUSTOM_SLIDER = preload("res://scenes/ui/custom_slider.tscn")
const CUSTOM_ARRAY = preload("res://scenes/ui/custom_array.tscn")

var state
enum State {
	NONE,
	BODY_SELECTED,
	EDIT_PANEL
}

func _ready() -> void:
	state = State.NONE

func update_custom_array(tag: String, data):
	for custom_array in get_tree().get_nodes_in_group("CustomArrays"):
		if custom_array.tag == tag:
			custom_array.silent_update(data)

func config_edit_panel(charge: Node3D):
	
	#Hardcoded dictionary for each body's details
	var config = charge.get_config_seed()
	
	$PanelContainer/Title.set_text(config["name"])
	
	for adjustment in config["adjustments"]:
		match adjustment["type"]:
			"slider":
				var slider = CUSTOM_SLIDER.instantiate()
				slider.initialize(adjustment)
				slider.edited.connect(charge.set_property)
				$PanelContainer/VBoxContainer.add_child(slider)
			"array":
				var array = CUSTOM_ARRAY.instantiate()
				match adjustment["tag"]:
					"position":
						array.initialize(adjustment, [charge.global_position.x, charge.global_position.y, charge.global_position.z])
					"rotation":
						array.initialize(adjustment, [charge.rotation.x, charge.rotation.y, charge.rotation.z])
				array.edited.connect(charge.set_property)
				$PanelContainer/VBoxContainer.add_child(array)
	
func _on_show_edit_panel_pressed() -> void:
	if state != State.EDIT_PANEL:
		config_edit_panel($"../Camera3D".selected.get_parent())
		state = State.EDIT_PANEL
		$PanelContainer/AnimationPlayer.play("enter_screen")
	else:
		state = State.BODY_SELECTED
		clear_panel()

func _on_camera_3d_ray_casted(collided: bool) -> void:
	if collided:
		state = State.BODY_SELECTED
		$ShowEditPanel/AnimationPlayer.play("enter_screen")
		$RemoveBody/AnimationPlayer.play("enter_screen")
	else:
		if state == State.EDIT_PANEL:
			clear_panel()
		state = State.NONE
		$ShowEditPanel/AnimationPlayer.play("exit_screen")
		$RemoveBody/AnimationPlayer.play("exit_screen")

func clear_panel():
	$PanelContainer/AnimationPlayer.play("exit_screen") 
	for component in $PanelContainer/VBoxContainer.get_children():
		component.queue_free()
