extends Area2D
class_name Monster

const MAX_CHARGES = 4

var cell: Vector2
var facing: Vector2

var charges := MAX_CHARGES

var is_moving: bool

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
