extends Control

var tabMenu:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	tabMenu = false
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("pop_up"):
		if tabMenu:
			tabMenu = false
			hide()
		else:
			tabMenu = true
			show()
