extends GameState

func enter(previous_state_path: String, data := {}) -> void:
	Globals.time_elapsed = 0
	game.start_screen.visible = true
	get_tree().paused = true

func exit() -> void:
	game.start_screen.visible = false
	get_tree().paused = false

func _start_game() -> void:
	finished.emit(PLAYING)
