extends Control
class_name TitleScreen

@onready var quit_button: Button = $HBoxContainer/QuitButton
static var show_intro := true

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

@onready var button_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	if OS.get_name() == "Web": quit_button.hide()
	if show_intro:
		button_container.modulate.a = 0
		label.modulate.a = 0
		label.text = "GMTK Game Jam 2023" 
		var tween = get_tree().create_tween()
		tween.set_parallel(false)
		tween.tween_property(label, "modulate:a", 1.0, 1.5)
		tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(2.0)
		tween.tween_callback(func(): label.text = "John Gabriel\nand Aaron Winter")
		tween.tween_property(label, "modulate:a", 1.0, 1.5)
		tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(2.0)
		tween.tween_callback(func(): label.text = "Present")
		tween.tween_property(label, "modulate:a", 1.0, 1.5)
		tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(2.0)
		tween.tween_callback(func(): Sfx.play("Laugh"))
		tween.tween_property(color_rect, "modulate:a", 0.0, 2.5)
		tween.tween_property(button_container, "modulate:a", 1.0, 1.5).set_delay(1.0)
		tween.tween_callback(func(): color_rect.hide())
		show_intro = false
	else:
		color_rect.hide()


func _on_play_button_pressed() -> void:
	Sfx.play("UIStart")
	get_tree().change_scene_to_file("res://src/level/level.tscn")


func _on_help_button_pressed() -> void:
	Sfx.play("UISelect")
	get_tree().change_scene_to_file("res://src/title_screen/help.tscn")


func _on_quit_button_pressed() -> void:
	Sfx.play("UISelect")
	get_tree().quit()


func _on_button_mouse_entered() -> void:
	Sfx.play("UIMove")


