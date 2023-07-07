extends Node2D
class_name Level

const GRID_SIZE := Vector2(16, 16)

@onready var monster: Node2D = $Monster


func _ready() -> void:
	monster.cell = (monster.position / GRID_SIZE).floor()


func _process(delta: float) -> void:
	var direction := get_input_direction()
	move_monster(direction)


func get_input_direction() -> Vector2:
	var x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return Vector2(x, y).normalized()


func move_monster(direction: Vector2) -> void:
	if not direction or monster.is_moving:
		return
	
	monster.cell = monster.cell + direction
	monster.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.tween_property(monster, "position", monster.cell * GRID_SIZE, 0.15)
	tween.tween_callback(func(): monster.is_moving = false)
