extends Node2D
class_name Level

const NEIGHBORS := [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, 1),
	Vector2(-1, -1),
]

const GRID_SIZE := Vector2(16, 16)

@onready var monster: Monster = $Monster
@onready var guard: Node2D = $Guard

@onready var tile_map: TileMap = $Maze
@onready var collision_layer := tile_map.tile_set.get_custom_data_layer_by_name("Solid")

@onready var cams: Node2D = $Cams

var active_camera: Cam
var current_camera: Cam


func _ready() -> void:
	monster.cell = (monster.position / GRID_SIZE).floor()
	monster.position = monster.cell * GRID_SIZE
	
	guard.cell = (guard.position / GRID_SIZE).floor()
	guard.position = guard.cell * GRID_SIZE
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()


func _process(delta: float) -> void:
	var direction := get_input_direction()
	move_monster(direction)


func get_input_direction() -> Vector2:
	var x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return Vector2(x, y)


func interact() -> void:
	for n_direction in NEIGHBORS:
		var n_cell = monster.cell + n_direction
		# TODO: interact with interactable things!


func move_monster(direction: Vector2) -> void:
	if not direction or monster.is_moving:
		return
	
	var new_cell = monster.cell + direction
	
	if is_solid(new_cell):
		return
	
	if direction.x and monster.facing.x: direction.y = 0
	if direction.y and monster.facing.y: direction.x = 0
	
	monster.facing = direction
	monster.cell = monster.cell + direction
	monster.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.tween_property(monster, "position", monster.cell * GRID_SIZE, 0.15)
	tween.tween_callback(func(): monster.is_moving = false)


func is_solid(cell: Vector2) -> bool:
	var is_solid := false
	var tile_data = tile_map.get_cell_tile_data(collision_layer, cell)
	if tile_data:
		is_solid = tile_data.get_custom_data("Solid") as bool
	return is_solid


func _on_monster_area_entered(area: Area2D) -> void:
	if area is Cam:
		current_camera = area
		print(current_camera.index)


func _on_monster_area_exited(area: Area2D) -> void:
	current_camera = null
	print("null")
