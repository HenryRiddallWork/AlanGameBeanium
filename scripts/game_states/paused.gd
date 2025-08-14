extends GameState

func enter(previous_state_path: String, data := {}) -> void:
	game.paused_layer.visible = true
	get_tree().paused = true

func exit() -> void:
	game.paused_layer.visible = false
	get_tree().paused = false

func _resume() -> void:
	finished.emit(PLAYING)
