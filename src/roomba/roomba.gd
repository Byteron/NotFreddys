extends Area2D
class_name Roomba

@onready var sprite : Sprite2D = $Sprite2D

var cell: Vector2
var facing: Vector2
var is_moving: bool

func set_sprite_facing() -> void:
	match facing:
		Vector2.LEFT: sprite.frame = 0
		Vector2.DOWN: sprite.frame = 1
		Vector2.RIGHT: sprite.frame = 2
		Vector2.UP: sprite.frame = 3
