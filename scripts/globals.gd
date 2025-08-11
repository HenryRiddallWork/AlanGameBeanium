extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	PAUSED,
	WIN_SCREEN
}
var gamestate = GAMESTATES.START_SCREEN

signal start_game
signal pause_game
signal resume_game
signal end_game

signal player_reset

# player state
const PLAYER_1_ID = "1"
const PLAYER_2_ID = "2"

const MAX_PLAYER_HEALTH = 30

class PlayerData:
	var health: int = MAX_PLAYER_HEALTH

var player_data: Dictionary = {
	PLAYER_1_ID: PlayerData.new(),
	PLAYER_2_ID: PlayerData.new(),
}

# counters
var time_elapsed: float = 0

func _reset_game_state() -> void:
	player_data[PLAYER_1_ID] = PlayerData.new()
	player_data[PLAYER_2_ID] = PlayerData.new()
	player_reset.emit()

func _ready() -> void:
	get_tree().paused = true

func start() -> void:
	gamestate = GAMESTATES.PLAYING
	start_game.emit()
	get_tree().paused = false
	print("starting game")
	resume()

func pause() -> void:
	gamestate = GAMESTATES.PAUSED
	pause_game.emit()
	get_tree().paused = true
	print("pausing game")

func resume() -> void:
	get_tree().paused = false
	gamestate = GAMESTATES.PLAYING
	resume_game.emit()
	print("resuming game")

func end() -> void:
	gamestate = GAMESTATES.WIN_SCREEN
	end_game.emit()
	get_tree().paused = true
 
func _process(delta: float) -> void:
	if gamestate == GAMESTATES.PLAYING:
		time_elapsed += delta
	if Input.is_action_just_pressed("Pause"):
		pause()
