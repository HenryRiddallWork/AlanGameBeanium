# Boilerplate class to get full autocompletion and type checks for the `game` when coding the games's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name GameState extends State

# States
const START_SCREEN = "StartScreen"
const PLAYING = "Playing"
const PAUSED = "Paused"
const END_GAME = "EndGame"

var game: Game

func _ready() -> void:
	await owner.ready
	game = owner as Game
	assert(game != null)
