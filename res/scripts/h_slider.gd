extends HSlider

var escena
@onready var label_2 = $Label2
@onready var label = $Label
	
func _ready():
	label.text = self.name
	if !self.visible:
		self.editable = false
	else: 
		self.editable = true
