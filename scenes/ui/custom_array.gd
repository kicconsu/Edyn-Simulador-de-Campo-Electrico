extends VBoxContainer

signal edited(tag: String, value: float)
var tag : String = ""
var editable = true

func initialize(config: Dictionary, start_values: Array):
	tag = config["tag"]
	$Title.set_text(config["name"])
	
	#Configure the settings for each slider
	for i in range(config["values"].size()):
		var value = config["values"][i]
		var box = $HBoxContainer.get_child(i)
		var textbox = box.get_child(0)
		
		if not config["editable"]:
			editable = false
			textbox.get_child(1).editable = false
			box.get_child(1).queue_free()
		else:
			box.get_child(1).min_value = value["min"]
			box.get_child(1).max_value = value["max"]
			
		#Label
		textbox.get_child(0).text = value["label"]
		#LineEdit
		textbox.get_child(1).text = str(start_values[i])
		#Units
		textbox.get_child(2).text = value["units"]



func silent_update(data: Vector3):
	if editable:
		$HBoxContainer/Var1/HSlider.set_value_no_signal(data.x)
		$HBoxContainer/Var2/HSlider.set_value_no_signal(data.y)
		$HBoxContainer/Var3/HSlider.set_value_no_signal(data.z)
	
	$HBoxContainer/Var1/HBoxContainer/LineEdit.disconnect("text_submitted", _on_line_edit_text_submitted)
	$HBoxContainer/Var1/HBoxContainer/LineEdit.text = str(data.x)
	$HBoxContainer/Var1/HBoxContainer/LineEdit.connect("text_submitted", _on_line_edit_text_submitted)
	
	$HBoxContainer/Var2/HBoxContainer/LineEdit.disconnect("text_submitted", _on_line_edit_text_submitted_2)
	$HBoxContainer/Var2/HBoxContainer/LineEdit.text = str(data.y)
	$HBoxContainer/Var2/HBoxContainer/LineEdit.connect("text_submitted", _on_line_edit_text_submitted_2)
	
	$HBoxContainer/Var3/HBoxContainer/LineEdit.disconnect("text_submitted", _on_line_edit_text_submitted_3)
	$HBoxContainer/Var3/HBoxContainer/LineEdit.text = str(data.z)
	$HBoxContainer/Var3/HBoxContainer/LineEdit.connect("text_submitted", _on_line_edit_text_submitted_3)



#WARNING: none of the following methods are relevant if the array is set to not be editable,
#as the sliders are gone
func _on_h_slider_value_changed(value: float) -> void:
	$HBoxContainer/Var1/HBoxContainer/LineEdit.text = str(value)
	edited.emit(tag, Vector3(value, 0,0))


func _on_h_slider_value_changed_2(value: float) -> void:
	$HBoxContainer/Var2/HBoxContainer/LineEdit.text = str(value)
	edited.emit(tag, Vector3(0,value,0))


func _on_h_slider_value_changed_3(value: float) -> void:
	$HBoxContainer/Var3/HBoxContainer/LineEdit.text = str(value)
	edited.emit(tag, Vector3(0, 0, value))
	



func _on_line_edit_text_submitted_3(new_text: String) -> void:
	var value = new_text.to_float()
	
	if not value:
		$HBoxContainer/Var3/HBoxContainer/LineEdit.text = str($HBoxContainer/Var3/HSlider.value)
	elif value >= $HBoxContainer/Var3/HSlider.min_value and value <= $HBoxContainer/Var3/HSlider.max_value:
		$HBoxContainer/Var3/HSlider.set_value_no_signal(value)
		edited.emit(tag, Vector3(0, 0, value))
	else:
		$HBoxContainer/Var3/HBoxContainer/LineEdit.text = str($HBoxContainer/Var3/HSlider.value)
	
	$HBoxContainer/Var3/HBoxContainer/LineEdit.release_focus()


func _on_line_edit_text_submitted_2(new_text: String) -> void:
	var value = new_text.to_float()
	
	if not value:
		$HBoxContainer/Var2/HBoxContainer/LineEdit.text = str($HBoxContainer/Var2/HSlider.value)
	elif value >= $HBoxContainer/Var2/HSlider.min_value and value <= $HBoxContainer/Var2/HSlider.max_value:
		$HBoxContainer/Var2/HSlider.set_value_no_signal(value)
		edited.emit(tag, Vector3(0,value,0))
	else:
		$HBoxContainer/Var2/HBoxContainer/LineEdit.text = str($HBoxContainer/Var2/HSlider.value)
	
	$HBoxContainer/Var2/HBoxContainer/LineEdit.release_focus()


func _on_line_edit_text_submitted(new_text: String) -> void:
	var value = new_text.to_float()
	
	if not value:
		$HBoxContainer/Var1/HBoxContainer/LineEdit.text = str($HBoxContainer/Var1/HSlider.value)
	elif value >= $HBoxContainer/Var1/HSlider.min_value and value <= $HBoxContainer/Var1/HSlider.max_value:
		$HBoxContainer/Var1/HSlider.set_value_no_signal(value)
		edited.emit(tag, Vector3(value, 0,0))
	else:
		$HBoxContainer/Var1/HBoxContainer/LineEdit.text = str($HBoxContainer/Var1/HSlider.value)
	
	$HBoxContainer/Var1/HBoxContainer/LineEdit.release_focus()
