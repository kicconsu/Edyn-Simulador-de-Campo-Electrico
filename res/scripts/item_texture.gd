extends TextureRect

@export var this_scene: PackedScene
@onready var object_cursor = get_node("/root/2dTest/Node2D/Editor_Object")
@onready var cursor_sprite = object_cursor.get_node("Sprite2D")

func _ready():
	connect("gui_input", _item_clicked)

#Se envia la escena del item selecionado
func _item_clicked(event):
	if event.is_action_pressed("mb_left"):
		object_cursor.current_item = this_scene
	
