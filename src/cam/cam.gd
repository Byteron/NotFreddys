extends Area2D
class_name Cam

var index: int
var is_active: bool


func _ready() -> void:
	index = get_index()
