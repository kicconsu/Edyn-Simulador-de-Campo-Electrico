extends CanvasLayer
@onready var anim = $anim
var chargeValue

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("glow")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_charge_slider_value_changed(value):
	pass # Replace with function body.


func _on_radius_slider_value_changed(value):
	pass # Replace with function body.
