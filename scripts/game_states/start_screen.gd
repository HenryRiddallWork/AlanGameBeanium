extends GameState

const INPUT_DELAY: float = 0.5
var time_paused: float = 0

func enter(previous_state_path: String, data := {}) -> void:
	time_paused = 0
	game.start_screen.visible = true
	Globals.player_1_wins = 0
	Globals.player_2_wins = 0
	get_tree().paused = true

func exit() -> void:
	game.start_screen.visible = false
	get_tree().paused = false

func _start_game() -> void:
	finished.emit(PLAYING)

func physics_update(_delta: float) -> void:
	if time_paused < INPUT_DELAY:
		time_paused += _delta
	if time_paused >= INPUT_DELAY && Input.is_action_just_pressed("Start"):
		finished.emit(PLAYING)
