extends Control

const _Message : PackedScene = preload("res://src/ui/message.tscn")

@onready var label_time : Label = $Label_Time
@onready var label_battery : Label = $Label_Battery
@onready var label_heartrate : Label = $Label_Heartrate
@onready var vbox_messages : VBoxContainer = $VBox_Messages

func set_time(hour : int, minute : int) -> void:
	label_time.text = "%02d:%02d AM" % [hour, minute]

func set_battery(battery : int) -> void:
	label_battery.text = "%d%%" % battery

func set_heart_rate(bpm : int) -> void:
	label_heartrate.text = "%d BPM" % bpm

func add_message(text : String) -> void:
	var message : Control = _Message.instantiate()
	message.set_message(text)
	vbox_messages.add_child(message)
	message.show_message()
