extends Area2D
class_name Monster

const MAX_CHARGE = 100.0

var cell: Vector2
var facing: Vector2

var charge := MAX_CHARGE

var is_moving: bool

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
