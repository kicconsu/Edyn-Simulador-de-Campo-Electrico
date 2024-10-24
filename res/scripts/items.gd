extends Control

@export var placeholder : Texture
@onready var texture = $Button/TextureRect

signal button_pressed()

func _ready():

	if texture and placeholder:
		texture.texture = placeholder
