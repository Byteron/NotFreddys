extends Control

const _Message : PackedScene = preload("res://src/ui/message.tscn")

@onready var label_time : Label = $Label_Time
@onready var label_battery : Label = $Label_Battery
@onready var label_heartrate : Label = $Label_Heartrate
@onready var vbox_messages : VBoxContainer = $VBox_Messages
@onready var texture_heartrate: TextureRect = $Texture_Heartrate

var bpm: int
var tween: Tween

func _process(delta: float) -> void:
	if bpm == 0:
		return
	
	var time = 60.0 / bpm
	var half_time = time / 2
	
	if tween != null:
		return
	
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property(texture_heartrate, "scale", Vector2(1.3, 1.3), half_time)
	tween.tween_property(texture_heartrate, "scale", Vector2.ONE, half_time)
	tween.tween_callback(func(): tween = null)


func _exit_tree() -> void:
	if tween:
		tween.stop()
		tween = null


func set_time(hour : int, minute : int) -> void:
	label_time.text = "%02d:%02d AM" % [hour, minute]


func set_battery(battery : int) -> void:
	label_battery.text = "%d%%" % battery
	if battery < 20:
		label_battery.modulate = Color.RED
	else:
		label_battery.modulate = Color.WHITE


func set_heart_rate(bpm : int) -> void:
	self.bpm = bpm
	label_heartrate.text = "%d BPM" % bpm
	
	if bpm < Guard.LOW_BPM:
		texture_heartrate.modulate = Color.WHITE
	elif bpm < Guard.MEDIUM_BPM:
		texture_heartrate.modulate = Color.YELLOW
	else:
		texture_heartrate.modulate = Color.ORANGE


func add_message(text : String) -> void:
	var message : Control = _Message.instantiate()
	message.set_message(text)
	vbox_messages.add_child(message)
	message.show_message()
