extends Node

@onready var player_1: Player = $Player1
@onready var player_2: Player = $Player2
@onready var game_boundary: Area2D = $GameBoundary

const COLLISION_HEALTH_SCALE_FACTOR = 0.1

const COLLISION_TIMEOUT: float = 0.7 # Seconds
var current_collision_timeout: float = 0

# These are set on load so that we can reset to the manual positions set in the editor
var player_1_initial_position: Vector2
var player_2_initial_position: Vector2


func _ready() -> void:
	Globals.player_reset.connect(_on_player_reset)
	game_boundary.body_exited.connect(_on_game_boundary_body_exited)
	player_1.player_collision.connect(_on_player_collision)
	player_2.player_collision.connect(_on_player_collision)
	player_1_initial_position = player_1.position
	player_2_initial_position = player_2.position


func _process(delta: float) -> void:
	if current_collision_timeout > 0:
		current_collision_timeout -= delta


func _on_player_collision(player_speeds: Dictionary) -> void:
	if current_collision_timeout <= 0:
		current_collision_timeout = COLLISION_TIMEOUT
		var player_1_speed: float = player_speeds[Globals.PLAYER_1_ID]
		var player_2_speed: float = player_speeds[Globals.PLAYER_2_ID]
		var player_1_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_2_speed)
		var player_2_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_1_speed)
		_damage_players(player_1_damage, player_2_damage)


func _damage_players(player_1_damage: int, player_2_damage: int) -> void:
	var player_1_new_health = max(0, Globals.player_data[Globals.PLAYER_1_ID].health - player_1_damage)
	var player_2_new_health = max(0, Globals.player_data[Globals.PLAYER_2_ID].health - player_2_damage)
	Globals.player_data[Globals.PLAYER_1_ID].health = player_1_new_health
	Globals.player_data[Globals.PLAYER_2_ID].health = player_2_new_health
	
	if player_1_new_health == 0 or player_2_new_health == 0:
		Globals.end()


func _on_game_boundary_body_exited(body: Node) -> void:
	Globals.end()


func _on_player_reset() -> void:
	player_1.position = player_1_initial_position
	player_2.position = player_2_initial_position
