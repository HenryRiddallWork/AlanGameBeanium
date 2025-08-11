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

# player state
const PLAYER_1_ID = "1"
const PLAYER_2_ID = "2"

class PlayerData:
	var health: int = 10

var player_data: Dictionary = {
	PLAYER_1_ID: PlayerData.new(),
	PLAYER_2_ID: PlayerData.new(),
}

# counters
var time_elapsed: float = 0


func _ready() -> void:
	get_tree().paused = true

func start():
	gamestate = GAMESTATES.PLAYING
	start_game.emit()
	get_tree().paused = false
	print("starting game")
	resume()

func pause():
	gamestate = GAMESTATES.PAUSED
	pause_game.emit()
	get_tree().paused = true
	print("pausing game")

func resume():
	get_tree().paused = false
	gamestate = GAMESTATES.PLAYING
	resume_game.emit()
	print("resuming game")

func _process(delta: float) -> void:
	if gamestate == GAMESTATES.PLAYING:
		time_elapsed += delta
	if Input.is_action_just_pressed("Paused"):
		pause()
