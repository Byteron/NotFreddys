extends Node2D
class_name Level

const DIRECTIONS4 := [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
]

const DIRECTIONS8 := [
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
@onready var roomba: Area2D = $Roomba

@onready var tile_map: TileMap = $Maze

@onready var cams: Node2D = $Cams
@onready var batteries: Node2D = $Batteries
@onready var intersections_container: Node2D = $Intersections

@onready var charges_rect: TextureRect = $CanvasLayer/ChargesRect

@export var battery_scene: PackedScene
@export var max_batteries: int

var active_camera: Cam
var current_camera: Cam

var intersections: Array[Vector2]
	

func _ready() -> void:
	monster.cell = (monster.position / GRID_SIZE).floor()
	monster.position = monster.cell * GRID_SIZE
	
	guard.cell = (guard.position / GRID_SIZE).floor()
	guard.position = guard.cell * GRID_SIZE
	
	roomba.cell = (roomba.position / GRID_SIZE).floor()
	roomba.position = roomba.cell * GRID_SIZE
	
	update_monster_charges()
	
	for marker in intersections_container.get_children():
		var cell = (marker.position / GRID_SIZE).floor()
		intersections.append(cell)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()


func _process(delta: float) -> void:
	var direction := get_input_direction()
	move_monster(direction)
	move_roomba()


func get_input_direction() -> Vector2:
	var x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return Vector2(x, y)


func interact() -> void:
	if monster.charges == 0:
		return
	
	update_monster_charges(-1)
	
	for n_direction in DIRECTIONS8:
		var n_cell = monster.cell + n_direction
		# TODO: interact with interactable things!


func update_monster_charges(delta: int = 0) -> void:
	monster.charges = clamp(monster.charges + delta, 0, Monster.MAX_CHARGES)
	var texture := charges_rect.texture as AtlasTexture
	texture.region.position.x = 72 * monster.charges


func move_monster(direction: Vector2) -> void:
	if not direction and not monster.is_moving:
		monster.anim.stop()
		monster.anim.seek(0, true)
	
	if not direction or monster.is_moving:
		return
	
	if direction.x and monster.facing.x: direction.y = 0
	if direction.y and monster.facing.y: direction.x = 0
	
	var new_cell = monster.cell + direction
	
	monster.facing = direction
	match monster.facing:
		Vector2.UP:
			monster.anim.play("walk_up")
		Vector2.DOWN:
			monster.anim.play("walk_down")
		Vector2.LEFT:
			monster.anim.play("walk_side")
			monster.sprite.flip_h = false
		Vector2.RIGHT:
			monster.anim.play("walk_side")
			monster.sprite.flip_h = true
	
	if not is_walkable(new_cell):
		return
	
	monster.cell = monster.cell + direction
	monster.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property(monster, "position", monster.cell * GRID_SIZE, 0.15)
	tween.tween_callback(func(): monster.is_moving = false)


func move_roomba() -> void:
	if roomba.is_moving:
		return
	
	if not roomba.facing or roomba.cell in intersections:
		var directions: Array[Vector2]
		for n_dir in DIRECTIONS4:
			var n_cell = roomba.cell + n_dir
			
			if not is_walkable(n_cell):
				continue
			
			if n_dir == -roomba.facing:
				continue
			
			directions.append(n_dir)
		var dir = directions.pick_random()
		roomba.facing = dir
	
	roomba.cell = roomba.cell + roomba.facing
	roomba.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property(roomba, "position", roomba.cell * GRID_SIZE, 0.15)
	tween.tween_callback(func(): roomba.is_moving = false)
	

func is_walkable(cell: Vector2) -> bool:
	for n_direction in DIRECTIONS8:
		var n_cell = guard.cell + n_direction
		if cell == n_cell:
			return false
	
	var solid := is_solid(cell)
	var walkable := false
	
	var floor_data = tile_map.get_cell_tile_data(1, cell)
	if floor_data:
		walkable = floor_data.get_custom_data("Walkable") as bool

	return walkable and not solid


func is_solid(cell: Vector2) -> bool:
	if cell == guard.cell or cell == monster.cell:
		return true
	
	var solid := false
	
	var wall_data = tile_map.get_cell_tile_data(0, cell)
	if wall_data:
		solid = wall_data.get_custom_data("Solid") as bool
	return solid


func _on_monster_area_entered(area: Area2D) -> void:
	if area is Cam:
		current_camera = area
		print(current_camera.index)


func _on_monster_area_exited(area: Area2D) -> void:
	current_camera = null
	print("-1")

func _on_battery_timer_timeout() -> void:
	if batteries.get_child_count() >= max_batteries:
		return
	
	var battery := battery_scene.instantiate() as Battery
	var cells = tile_map.get_used_cells(1)
	for i in range(cells.size() -1, -1, -1):
		var cell = cells[i]
		if not is_walkable(cell):
			cells.erase(cell)
	
	var cell = cells.pick_random()
	battery.position = Vector2(cell.x, cell.y) * GRID_SIZE
	batteries.add_child(battery)
	
	battery.area_entered.connect(func(area: Area2D):
		if area is Monster:
			update_monster_charges(1)
			battery.queue_free()
	)
