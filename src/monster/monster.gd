extends Area2D
class_name Monster

var cell: Vector2
var facing: Vector2
var is_moving: bool

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
