extends GameState

# Get player positions at the start of the game so that we can reset to where
# they are placed in the editor rather than hardcoded values
var player_1_initial_position: Vector2
var player_2_initial_position: Vector2

func enter(previous_state_path: String, data := {}) -> void:
	game.start_screen.start_game_triggered.connect(_start_game)
	player_1_initial_position = game.player_1.global_position
	player_2_initial_position = game.player_2.global_position
	game.start_screen.visible = true
	game.player_1.reset_player(player_1_initial_position)
	game.player_2.reset_player(player_2_initial_position)
	Globals.time_elapsed = 0
	get_tree().paused = true

func exit() -> void:
	game.start_screen.visible = false
	get_tree().paused = false

func _start_game() -> void:
	finished.emit(PLAYING)
