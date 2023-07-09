extends Node

var sfx: Dictionary


func _ready() -> void:
	for child in get_children():
		sfx[child.name] = child


func play(sfx_name: String):
	sfx[sfx_name].play()
