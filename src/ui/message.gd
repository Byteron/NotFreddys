extends Label

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func set_message(message : String) -> void:
	text = message

func show_message() -> void:
	anim_player.play("message")

func _on_animation_player_animation_finished(anim_name : String) -> void:
	queue_free()
