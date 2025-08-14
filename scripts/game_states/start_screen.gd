extends GameState

func _ready() -> void:
	await game.ready
	game.start_screen.start_game_triggered.connect(_start_game)

func enter(previous_state_path: String, data := {}) -> void:
	game.start_screen.visible = true
	Globals.time_elapsed = 0
	get_tree().paused = true

func exit() -> void:
	game.start_screen.visible = false
	get_tree().paused = false

func _start_game() -> void:
	finished.emit(PLAYING)
