extends Node

@onready var player_1_health: Label = $Player1Health
@onready var player_2_health: Label = $Player2Health
@onready var player_1: Player = $Player1
@onready var player_2: Player = $Player2

const COLLISION_TIMEOUT: float = 1
var current_collision_timeout: float = 0


func _ready() -> void:
	player_1_health.text = str(Globals.player_data[Globals.PLAYER_1_ID].health)
	player_2_health.text = str(Globals.player_data[Globals.PLAYER_2_ID].health)
	player_1.player_collision.connect(_on_player_collision)
	player_2.player_collision.connect(_on_player_collision)


func _process(delta: float) -> void:
	if current_collision_timeout > 0:
		current_collision_timeout -= delta


func _on_player_collision(player_speeds: Dictionary) -> void:
	if current_collision_timeout <= 0:
		var player_1_speed: float = player_speeds[Globals.PLAYER_1_ID]
		var player_2_speed: float = player_speeds[Globals.PLAYER_2_ID]
		print("Collision!!!")
		print("Player 1 speed: ", player_1_speed)
		print("Player 2 speed: ", player_2_speed)
		current_collision_timeout = COLLISION_TIMEOUT
