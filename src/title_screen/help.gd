extends Control
class_name HelpScreen


func _on_back_button_pressed() -> void:
	Sfx.play("UISelect")
	get_tree().change_scene_to_file("res://src/title_screen/title_screen.tscn")


func _on_back_button_mouse_entered() -> void:
	Sfx.play("UIMove")
