extends GameState

const INPUT_DELAY: float = 0.5
var time_paused: float = 0

func enter(previous_state_path: String, data := {}) -> void:
	time_paused = 0
	game.paused_layer.visible = true
	get_tree().paused = true

func exit() -> void:
	game.paused_layer.visible = false
	get_tree().paused = false

func _resume() -> void:
	finished.emit(PLAYING)
	
func update(delta: float) -> void:
	if time_paused < INPUT_DELAY:
		time_paused += delta
	if time_paused >= INPUT_DELAY && Input.is_action_just_pressed("Start"):
		_resume()
