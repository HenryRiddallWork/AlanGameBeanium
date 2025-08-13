extends GameState

func enter(previous_state_path: String, data := {}) -> void:
	game.end_screen.visible = true
	get_tree().paused = true

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		finished.emit(START_SCREEN)

func exit() -> void:
	game.end_screen.visible = false
	get_tree().paused = false
