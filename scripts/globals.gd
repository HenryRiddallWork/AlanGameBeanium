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


# counters
var player_health: int = 3
var time_elapsed: float = 0


func _ready() -> void:
	pass
	
func start():
	gamestate = GAMESTATES.PLAYING
	start_game.emit()
	get_tree().paused = false
	## kill mobs
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
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
