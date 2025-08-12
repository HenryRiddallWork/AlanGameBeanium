extends GameState

func enter(previous_state_path: String, data := {}) -> void:
	game.end_screen.visible = true
	get_tree().paused = true

func exit() -> void:
	game.end_screen.visible = false
	get_tree().paused = false
