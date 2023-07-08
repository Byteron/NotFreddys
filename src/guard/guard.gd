extends Node2D
class_name Guard

const LOW_BPM_PHASES := [
	"meh.",
	"*yawn*",
]

const MEDIUM_BPM_PHASES := [
	"Huh!",
	"Uhh ohh..",
]

const HIGH_BPM_PHASES := [
	"AHHHRGH!",
	"WHAAAA!",
]

const LOW_BPM := 90
const MEDIUM_BPM := 120

var cell: Vector2
var bpm: float

@onready var label: Label = $Label
