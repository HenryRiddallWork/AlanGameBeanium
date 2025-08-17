extends GameState

func enter(previous_state_path: String, data := {}) -> void:
	game.end_screen.visible = true
	if data["is_winner_player_1"]:
		game.end_screen.set_winner_text("Player 1 Wins!")
	else:
		game.end_screen.set_winner_text("Player 2 Wins!")
	game.player_1.process_mode = Node.PROCESS_MODE_DISABLED
	game.player_2.process_mode = Node.PROCESS_MODE_DISABLED

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
