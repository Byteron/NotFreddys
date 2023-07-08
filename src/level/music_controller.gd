extends Node

@onready var music_calm : AudioStreamPlayer = $Music_Calm
@onready var music_caution : AudioStreamPlayer = $Music_Caution
@onready var music_panic : AudioStreamPlayer = $Music_Panic

func start() -> void:
	music_calm.play()
	music_caution.play()
	music_panic.play()

func switch_to_calm() -> void:
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(music_calm, "volume_db", 0.0, 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(music_caution, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(music_panic, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)

func switch_to_caution() -> void:
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(music_calm, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(music_caution, "volume_db", 0.0, 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(music_panic, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)

func switch_to_panic() -> void:
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(music_calm, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(music_caution, "volume_db", -40.0, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(music_panic, "volume_db", 0.0, 1.0).set_ease(Tween.EASE_OUT)
