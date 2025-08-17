extends GameState

const COLLISION_HEALTH_SCALE_FACTOR = 0.25
const COLLISION_SCREEN_SHAKE_SCALE_FACTOR = 0.07

const COLLISION_TIMEOUT = 0.7 # Seconds
var current_collision_timeout = 0

const INPUT_DELAY: float = 0.5
var time_paused: float = 0

@onready var player_1: RigidBody2D = $"../../Player1"
@onready var player_2: RigidBody2D = $"../../Player2"
@onready var player_1_spawn = $"../../PlayerSpawn1"
@onready var player_2_spawn = $"../../PlayerSpawn2"

func enter(previous_state_path: String, data := {}) -> void:
	time_paused = 0
	if previous_state_path == PAUSED:
		return
	Globals.time_elapsed = 0
	Globals.winner = ""
	
	Globals.player_data[Globals.PLAYER_1_ID].health = Globals.MAX_PLAYER_HEALTH
	player_1.linear_velocity = Vector2.ZERO
	player_1.position = player_1_spawn.position
	player_1.rotation = 0
	player_1._ready()
	
	Globals.player_data[Globals.PLAYER_2_ID].health = Globals.MAX_PLAYER_HEALTH
	player_2.position = player_2_spawn.position
	player_2.linear_velocity = Vector2.ZERO
	player_2.rotation = 0
	player_2._ready()

func update(_delta: float) -> void:
	Globals.time_elapsed += _delta
	if current_collision_timeout > 0:
		current_collision_timeout -= _delta
	if time_paused < INPUT_DELAY:
		time_paused += _delta
	if time_paused >= INPUT_DELAY && Input.is_action_just_pressed("Start"):
		finished.emit(PAUSED)

func _on_player_collision(data: Dictionary) -> void:
	if current_collision_timeout <= 0:
		current_collision_timeout = COLLISION_TIMEOUT
		var p1_vel: Vector2 = data["player_1_velocity"]
		var p2_vel: Vector2 = data["player_2_velocity"]
		var p1_pos: Vector2 = data["player_1_pos"]
		var p2_pos: Vector2 = data["player_2_pos"]
		
		# Using the normal of the two player positions doesn't seem to work, maybe because
		# if you use normal A -> B then either A moving away from B or B moving away from A is going to give the wrong result

		var damage = floor((p1_vel.length() - p2_vel.length()) * COLLISION_HEALTH_SCALE_FACTOR)
		
		if damage > 0:
			_damage_players(0, damage)
		else:
			_damage_players(abs(damage), 0)
		$"../../Camera2D".shake(1, damage * COLLISION_SCREEN_SHAKE_SCALE_FACTOR)

func _damage_players(player_1_damage: int, player_2_damage: int) -> void:
	var player_1_new_health = Globals.player_data[Globals.PLAYER_1_ID].health - player_1_damage
	var player_2_new_health = Globals.player_data[Globals.PLAYER_2_ID].health - player_2_damage
	Globals.player_data[Globals.PLAYER_1_ID].health = player_1_new_health
	Globals.player_data[Globals.PLAYER_2_ID].health = player_2_new_health
	if player_1_new_health <= 0 or player_2_new_health <= 0:
		if player_1_new_health < player_2_new_health:
			Globals.winner = "2"
		else:
			Globals.winner = "1"
		finished.emit(END_GAME)

func _on_game_boundary_body_exited(body: Node) -> void:
	if body.is_in_group("Players") && Globals.winner == "":
		if body.name == "Player1":
			Globals.winner = "2"
		else:
			Globals.winner = "1"
		finished.emit(END_GAME)
