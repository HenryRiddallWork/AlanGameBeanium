extends GameState

const INPUT_DELAY: float = 1.5
var time_counter: float = 0

func enter(previous_state_path: String, data := {}) -> void:
	game.end_screen.play_konked()
	time_counter = 0
	if Globals.winner == "1":
		Globals.player_1_wins += 1
		game.end_screen.set_winner_text("Player 1 Wins!")
	else:
		Globals.player_2_wins += 1
		game.end_screen.set_winner_text("Player 2 Wins!")
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.15).timeout
	disable_players()
	Engine.time_scale = 1
	game.end_screen.visible = true

func exit() -> void:
	game.end_screen.visible = false
	call_deferred("enable_players")

func enable_players():
	game.player_1.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.player_2.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.player_1.unhook()
	game.player_2.unhook()

func disable_players():
	game.player_1.process_mode = Node.PROCESS_MODE_DISABLED
	game.player_2.process_mode = Node.PROCESS_MODE_DISABLED

func physics_update(_delta: float) -> void:
	if time_counter < INPUT_DELAY:
		time_counter += _delta
	if time_counter >= INPUT_DELAY:
		if Input.is_action_just_pressed("shoot_1") or Input.is_action_just_pressed("shoot_2"):
			finished.emit(PLAYING)
		if Input.is_action_just_pressed("Start"):
			get_tree().change_scene_to_file("res://scenes/world.tscn")
