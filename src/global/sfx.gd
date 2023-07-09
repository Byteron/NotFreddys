extends Node

var sfx: Dictionary


func _ready() -> void:
	for child in get_children():
		sfx[child.name] = child


func play(sfx_name: String) -> void:
	var player: AudioStreamPlayer = sfx[sfx_name]
	
	if player.playing:
		return
	
	player.play()


func stop(sfx_name: String) -> void:
	var player: AudioStreamPlayer = sfx[sfx_name]
	player.stop()
