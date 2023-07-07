extends Node2D
class_name Level

const GRID_SIZE := Vector2(16, 16)

@onready var monster: Monster = $Monster
@onready var guard: Node2D = $Guard

@onready var tile_map: TileMap = $TileMap
@onready var collision_layer := tile_map.tile_set.get_custom_data_layer_by_name("Solid")


func _ready() -> void:
	monster.cell = (monster.position / GRID_SIZE).floor()
	monster.position = monster.cell * GRID_SIZE
	
	guard.cell = (guard.position / GRID_SIZE).floor()
	guard.position = guard.cell * GRID_SIZE


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
	
	var new_cell = monster.cell + direction
	
	var is_solid := false
	var tile_data = tile_map.get_cell_tile_data(collision_layer, new_cell)
	if tile_data != null:
		is_solid = tile_data.get_custom_data("Solid") as bool
	
	if is_solid:
		return
	
	monster.cell = monster.cell + direction
	monster.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.tween_property(monster, "position", monster.cell * GRID_SIZE, 0.15)
	tween.tween_callback(func(): monster.is_moving = false)
