extends Node

@onready var player_1_health: Label = $Player1Health
@onready var player_2_health: Label = $Player2Health
@onready var player_1: Player = $Player1
@onready var player_2: Player = $Player2

const COLLISION_HEALTH_SCALE_FACTOR = 0.1

const COLLISION_TIMEOUT: float = 0.7 # Seconds
var current_collision_timeout: float = 0


func _ready() -> void:
	player_1.player_collision.connect(_on_player_collision)
	player_2.player_collision.connect(_on_player_collision)
	_update_player_health_labels()


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
	Globals.player_data[Globals.PLAYER_1_ID].health = max(0, Globals.player_data[Globals.PLAYER_1_ID].health - player_1_damage)
	Globals.player_data[Globals.PLAYER_2_ID].health = max(0, Globals.player_data[Globals.PLAYER_2_ID].health - player_2_damage)
	_update_player_health_labels()


func _update_player_health_labels() -> void:
	player_1_health.text = str(Globals.player_data[Globals.PLAYER_1_ID].health)
	player_2_health.text = str(Globals.player_data[Globals.PLAYER_2_ID].health)
