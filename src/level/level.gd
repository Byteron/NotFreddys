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

enum MonsterAction {
	APPEAR,
	PERFECT_APPEAR,
	LAUGH,
	INTERACT,
}

@onready var monster: Monster = $Monster
@onready var guard: Node2D = $Guard
@onready var roomba: Area2D = $Roomba

@onready var tile_map: TileMap = $Maze

@onready var cams: Node2D = $Cams
@onready var batteries: Node2D = $Batteries
@onready var intersections_container: Node2D = $Intersections
@onready var solids_container: Node2D = $Solids
@onready var interactables_container: Node2D = $Interactables

@onready var switch_camera_timer: Timer = $SwitchCameraTimer

@onready var hud : Control = $CanvasLayer/HUD

@onready var music_controller : Node = $MusicController

@export var battery_scene: PackedScene

@export var max_batteries: int
@export var charge_per_battery: float
@export var charge_per_step: float
@export var charge_per_interaction: float
@export var charge_per_laugh: float
@export var charge_per_hit: float

@export var start_bpm: float
@export var min_bpm: float
@export var max_bpm: float
@export var bpmrps: float
@export var bpm_per_laugh: float
@export var bpm_per_interact: float
@export var bpm_per_appear: float
@export var bpm_per_appear_better: float
@export var camera_connect_time: float

@export var monster_speed: float
@export var roomba_speed: float

@export var start_time: int
@export var time_scale: float

var active_camera: Cam
var current_camera: Cam

var intersections: Array[Vector2]
var solids: Array[Vector2]
var interactables: Dictionary

var time: float

var action_history: Array[int]
var action_multiplier: float

var phrase_history: Array[String]

var appears: int
var perfect_appears: int
var laughs: int
var noises: int
var batteries_collected: int
var zapped_by_roomba: int
var multiplier_sum: float
var multiplier_count: float
var spook_total: int


func _ready() -> void:
	time = start_time

	monster.cell = (monster.position / GRID_SIZE).floor()
	monster.position = monster.cell * GRID_SIZE
	
	guard.cell = (guard.position / GRID_SIZE).floor()
	guard.position = guard.cell * GRID_SIZE
	guard.bpm = start_bpm
	
	roomba.cell = (roomba.position / GRID_SIZE).floor()
	roomba.position = roomba.cell * GRID_SIZE
	
	update_monster_charge()
	
	for marker in intersections_container.get_children():
		var cell = (marker.position / GRID_SIZE).floor()
		intersections.append(cell)
	
	for marker in solids_container.get_children():
		var cell = (marker.position / GRID_SIZE).floor()
		solids.append(cell)
	
	for interactable in interactables_container.get_children():
		var cell = (interactable.position / GRID_SIZE).floor()
		interactables[cell] = interactable
	
	randomize()
	connect_to_camera(randi() % cams.get_child_count())
	
	music_controller.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
	
	if event.is_action_pressed("laugh"):
		laugh()


func _process(delta: float) -> void:
	var direction := get_input_direction()
	move_monster(direction)
	move_roomba()
	update_bpm(bpmrps * delta)
	update_time(delta)
	
	for n_direction in DIRECTIONS8:
		var n_cell = guard.cell + n_direction
		if monster.cell == n_cell:
			end_level()
			

func push_action_history(action: MonsterAction) -> void:
	if action_history.size() == 3:
		action_history.pop_front()
	
	action_history.append(action)
	
	match action:
		MonsterAction.LAUGH: laughs += 1
		MonsterAction.APPEAR: appears += 1
		MonsterAction.PERFECT_APPEAR: 
			appears += 1
			perfect_appears += 1
		MonsterAction.INTERACT: noises += 1
	
	var count: int
	var visited: Array[int]
	for a in action_history:
		if not a in visited:
			count += 1
		visited.append(a)
	
	action_multiplier = count
	multiplier_count += 1
	multiplier_sum += action_multiplier


func update_time(delta: float) -> void:
	time += delta * time_scale
	var hours = int(time / 60)
	hours = hours if hours > 0 else 12
	var minutes = int(time) % 60
	hud.set_time(hours, floor(minutes / 5.0) * 5.0)
	
	if time >= 360.0:
		set_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
	
		await get_tree().create_timer(1).timeout
		Sfx.stop("LowBattery")
		get_tree().change_scene_to_file("res://src/game_over/out_of_time.tscn")


func get_input_direction() -> Vector2:
	var x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return Vector2(x, y)


func interact() -> void:
	for n_direction in DIRECTIONS8:
		var n_cell = monster.cell + n_direction
		
		if n_cell in interactables:
			var interactable: NoiseTrap = interactables[n_cell]
			interactable.anim.play("on")
			push_action_history(MonsterAction.INTERACT)
			spook_guard(bpm_per_interact)
			var timer = get_tree().create_timer(7.36)
			Sfx.play(interactable.sfx_name)
			timer.timeout.connect(func():
				interactable.anim.play("off")
			)
			update_monster_charge(charge_per_interaction)
			return


func laugh() -> void:
	push_action_history(MonsterAction.LAUGH)
	spook_guard(bpm_per_laugh)
	update_monster_charge(charge_per_laugh)
	Sfx.play("Laugh")


func update_monster_charge(delta := 0.0) -> void:
	monster.charge = clamp(monster.charge + delta, 0, Monster.MAX_CHARGE)
	hud.set_battery(monster.charge)
	
	if monster.charge <= 20:
		Sfx.play("LowBattery")
	else:
		Sfx.stop("LowBattery")
	
	if monster.charge <= 0:
		set_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
	
		await get_tree().create_timer(1).timeout
		
		Sfx.stop("LowBattery")
		get_tree().change_scene_to_file("res://src/game_over/out_of_battery.tscn")


func end_level() -> void:
	EndScreen.spook_total = spook_total
	EndScreen.bpm = guard.bpm
	EndScreen.time = time
	EndScreen.appears = appears
	EndScreen.perfect_appears = perfect_appears
	EndScreen.multiplier_average = multiplier_sum / multiplier_count
	EndScreen.laughs = laughs
	EndScreen.noises = noises
	EndScreen.zapped_by_roomba = zapped_by_roomba
	EndScreen.batteries_collected = batteries_collected
	
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	
	await get_tree().create_timer(1).timeout
	Sfx.stop("LowBattery")
	get_tree().change_scene_to_file("res://src/end_screen/end_screen.tscn")


func update_bpm(delta := 0.0) -> void:
	guard.bpm = clamp(guard.bpm + delta * action_multiplier, min_bpm, max_bpm)
	
	hud.set_heart_rate(guard.bpm)
	
	if guard.bpm < Guard.LOW_BPM:
		music_controller.switch_to_calm()
	elif guard.bpm < Guard.MEDIUM_BPM:
		music_controller.switch_to_caution()
	else:
		music_controller.switch_to_panic()
	
	if delta > 0.1:
		spook_total += delta * action_multiplier
		print("Delta: %d, Mult: %d" % [delta, action_multiplier])


func connect_to_camera(index: int) -> void:
	if active_camera:
		active_camera.cam_sprite.frame = 0
		active_camera.light_sprite.modulate = Color.WHITE
		active_camera.light_sprite.modulate.a8 = 20
		active_camera = null
		Sfx.play("UIBack")
	
	if index == -1:
		return
	
	Sfx.play("UISelect")
	var cam: Cam = cams.get_child(index)
	cam.cam_sprite.frame = 1
	cam.light_sprite.modulate = Color.WHEAT
	cam.light_sprite.modulate.a8 = 80
	var timer = get_tree().create_timer(camera_connect_time)
	timer.timeout.connect(func():
		cam.cam_sprite.frame = 2
		cam.light_sprite.modulate = Color.GREEN
		cam.light_sprite.modulate.a8 = 80
		active_camera = cam
		Sfx.play("UIStart")
		
		if current_camera != active_camera:
			return
		
		push_action_history(MonsterAction.PERFECT_APPEAR)
		spook_guard(bpm_per_appear_better, true)
	)


func spook_guard(delta: float, disconnect_from_camera := false) -> void:
	update_bpm(delta)
	if disconnect_from_camera:
		connect_to_camera(-1)
		switch_camera_timer.start()
	
	var phrase: String
	if guard.bpm < Guard.LOW_BPM:
		phrase = Guard.LOW_BPM_PHASES.pick_random()
	elif guard.bpm < Guard.MEDIUM_BPM:
		phrase = Guard.MEDIUM_BPM_PHASES.pick_random()
	else:
		phrase = Guard.HIGH_BPM_PHASES.pick_random()
	
	hud.add_message(phrase)


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
	
	Sfx.play("Footstep")
	
	monster.cell = new_cell
	monster.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property(monster, "position", monster.cell * GRID_SIZE, monster_speed)
	tween.tween_callback(func(): monster.is_moving = false)
	
	update_monster_charge(charge_per_step)


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
		
		if directions.size() == 0:
			roomba.facing = -roomba.facing
		else:
			var dir = directions.pick_random()
			roomba.facing = dir
	
	roomba.cell = roomba.cell + roomba.facing
	roomba.is_moving = true
	
	var tween := get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property(roomba, "position", roomba.cell * GRID_SIZE, roomba_speed)
	tween.tween_callback(func(): roomba.is_moving = false)
	

func is_walkable(cell: Vector2) -> bool:
	var solid := is_solid(cell)
	var walkable := false
	
	var floor_data = tile_map.get_cell_tile_data(1, cell)
	if floor_data:
		walkable = floor_data.get_custom_data("Walkable") as bool

	return walkable and not solid


func is_solid(cell: Vector2) -> bool:
	if cell == guard.cell or cell == monster.cell:
		return true
	
	if cell in solids:
		return true
	
	var solid := false
	
	var wall_data = tile_map.get_cell_tile_data(0, cell)
	if wall_data:
		solid = wall_data.get_custom_data("Solid") as bool
	return solid


func _on_monster_area_entered(area: Area2D) -> void:
	if area is Cam:
		current_camera = area
		
		if current_camera != active_camera:
			return
	
		push_action_history(MonsterAction.APPEAR)
		spook_guard(bpm_per_appear, true)


func _on_monster_area_exited(area: Area2D) -> void:
	current_camera = null


func is_next_to_guard(cell: Vector2) -> bool:
	for n_dir in DIRECTIONS8:
		var n_cell = cell + n_dir
		if guard.cell == n_cell:
			return true
	return false


func _on_battery_timer_timeout() -> void:
	if batteries.get_child_count() >= max_batteries:
		return
	
	var battery := battery_scene.instantiate() as Battery
	var cells = tile_map.get_used_cells(1)
	for i in range(cells.size() -1, -1, -1):
		var cell = cells[i]
		if not is_walkable(cell):
			cells.erase(cell)
		if is_next_to_guard(cell):
			cells.erase(cell)
	
	var cell = cells.pick_random()
	battery.position = Vector2(cell.x, cell.y) * GRID_SIZE
	batteries.add_child(battery)
	
	battery.area_entered.connect(_on_battery_collected.bind(battery))


func _on_battery_collected(area: Area2D, battery: Battery):
	if area is Monster:
		batteries_collected += 1
		battery.queue_free()
		update_monster_charge(charge_per_battery)
		Sfx.play("CollectBattery")


func _on_roomba_area_entered(area: Area2D) -> void:
	if area is Monster:
		zapped_by_roomba += 1
		update_monster_charge(charge_per_hit)
		Sfx.play("Zapped")


func _on_switch_camera_timer_timeout() -> void:
	var indices: Array[int]
	for i in cams.get_child_count():
		indices.append(i)
	
	if active_camera:
		indices.erase(active_camera.index)
	
	var index: int = indices.pick_random()
	
	connect_to_camera(index)
