extends Control
class_name EndScreen

static var time: float
static var bpm: int
static var appears: int
static var perfect_appears: int
static var laughs: int
static var noises: int
static var spook_total: int
static var batteries_collected: int
static var zapped_by_roomba: int
static var multiplier_average: float

@onready var label: Label = $CenterContainer/VBoxContainer/Label


func _ready() -> void:
	var hour = time / 60
	var minute = int(time) % 60
	
	var s := ""
	s += "Time: %02d:%02d AM" % [hour, snapped(minute, 5)]
	s += "\nTotal Spook Points: %d" % spook_total
	s += "\nBPM: %d" % bpm
	s += "\nCam Spooks: %d" % appears
	s += "\nPerfect Cam Spooks: %d" % perfect_appears
	s += "\nLaughs: %d" % laughs
	s += "\nNoises: %d" % noises
	s += "\nBatteries Collected: %d" % batteries_collected
	s += "\nMultiplier Average: %f" % multiplier_average

	label.text = s


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/title_screen/title_screen.tscn")
