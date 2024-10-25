extends CanvasLayer

const CUSTOM_SLIDER = preload("res://scenes/ui/custom_slider.tscn")

var state
enum State {
	NONE,
	BODY_SELECTED,
	EDIT_PANEL
}

func _ready() -> void:
	state = State.NONE

func _process(_delta: float) -> void:
	pass

func config_edit_panel(charge):
	
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
				pass
	
func _on_show_edit_panel_pressed() -> void:
	if state != State.EDIT_PANEL:
		config_edit_panel($"../Camera3D".selected.get_parent())
		state = State.EDIT_PANEL
		$PanelContainer/AnimationPlayer.play("enter_screen")
	else:
		state = State.BODY_SELECTED
		$PanelContainer/AnimationPlayer.play("exit_screen") 

func _on_camera_3d_ray_casted(collided: bool) -> void:
	if collided:
		state = State.BODY_SELECTED
		$ShowEditPanel/AnimationPlayer.play("enter_screen")
		$RemoveBody/AnimationPlayer.play("enter_screen")
	else:
		if state == State.EDIT_PANEL:
			$PanelContainer/AnimationPlayer.play("exit_screen") 
		state = State.NONE
		$ShowEditPanel/AnimationPlayer.play("exit_screen")
		$RemoveBody/AnimationPlayer.play("exit_screen")
