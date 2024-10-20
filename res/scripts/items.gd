extends Control

@export var placeholder : Texture
@onready var texture = $Button/TextureRect

func _ready():

	if texture and placeholder:
		texture.texture = placeholder
