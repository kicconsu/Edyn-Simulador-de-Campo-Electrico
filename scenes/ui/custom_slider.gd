extends VBoxContainer



signal edited(tag: String, value: float)
var tag = ""

func initialize(config: Dictionary):
	tag = config["tag"]
	$Title.set_text(config["name"])
	
	$VBoxContainer/HSlider.min_value = config["min"]
	$VBoxContainer/HSlider.max_value = config["max"]
	
	$VBoxContainer/HSlider.set_value_no_signal(config["value"])
	$VBoxContainer/HBoxContainer/Data.text = str(config["value"])
	$VBoxContainer/HBoxContainer/Units.set_text(config["units"])




func _on_h_slider_value_changed(value: float) -> void:
	$VBoxContainer/HBoxContainer/Data.text = str(value)
	edited.emit(tag, value)




func _on_data_text_submitted(new_text: String) -> void:
	var value = new_text.to_float()
	
	if not value:
		$VBoxContainer/HBoxContainer/Data.text = str($VBoxContainer/HSlider.value)
	elif value >= $VBoxContainer/HSlider.min_value and value <= $VBoxContainer/HSlider.max_value:
		$VBoxContainer/HSlider.set_value_no_signal(value)
		edited.emit(tag, value)
	else:
		$VBoxContainer/HBoxContainer/Data.text = str($VBoxContainer/HSlider.value)
