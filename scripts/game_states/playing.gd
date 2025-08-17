extends GameState

const COLLISION_HEALTH_SCALE_FACTOR = 0.1
const COLLISION_SCREEN_SHAKE_SCALE_FACTOR = 0.07

const COLLISION_TIMEOUT = 0.7 # Seconds
var current_collision_timeout = 0

@onready var player_1 = $"../../Player1"
@onready var player_2 = $"../../Player2"
@onready var player_1_spawn = $"../../PlayerSpawn1"
@onready var player_2_spawn = $"../../PlayerSpawn2"

func enter(previous_state_path: String, data := {}) -> void:
	Globals.time_elapsed = 0
	Globals.winner = ""
	
	Globals.player_data[Globals.PLAYER_1_ID].health = Globals.MAX_PLAYER_HEALTH
	player_1.linear_velocity = Vector2.ZERO
	player_1.position = player_1_spawn.position
	player_1.rotation = 0
	
	Globals.player_data[Globals.PLAYER_2_ID].health = Globals.MAX_PLAYER_HEALTH
	player_2.position = player_2_spawn.position
	player_2.linear_velocity = Vector2.ZERO
	player_2.rotation = 0

func update(_delta: float) -> void:
	Globals.time_elapsed += _delta
	if current_collision_timeout > 0:
		current_collision_timeout -= _delta
	if Input.is_action_just_pressed("Start"):
		finished.emit(PAUSED)

func _on_player_collision(player_speeds: Dictionary) -> void:
	if current_collision_timeout <= 0:
		current_collision_timeout = COLLISION_TIMEOUT
		var player_1_speed: float = player_speeds[Globals.PLAYER_1_ID]
		var player_2_speed: float = player_speeds[Globals.PLAYER_2_ID]
		var player_1_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_2_speed)
		var player_2_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_1_speed)
		_damage_players(player_1_damage, player_2_damage)
		$"../../Camera2D".shake(1, (player_1_speed + player_2_speed) * COLLISION_SCREEN_SHAKE_SCALE_FACTOR)

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
