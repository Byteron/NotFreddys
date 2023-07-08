extends Area2D
class_name Cam

var index: int
var is_active: bool

@onready var light_sprite: Sprite2D = $LightSprite2D
@onready var cam_sprite: Sprite2D = $CamSprite2D


func _ready() -> void:
	index = get_index()
