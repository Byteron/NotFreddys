extends Control
class_name TitleScreen

@onready var quit_button: Button = $HBoxContainer/QuitButton

func _ready() -> void:
	if OS.get_name() == "Web": quit_button.hide()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/level/level.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
