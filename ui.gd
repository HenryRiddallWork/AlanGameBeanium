extends Control

@onready var progress_bar_1: ProgressBar = $Player1HealthBar
@onready var progress_bar_2: ProgressBar = $Player2HealthBar

func _ready() -> void:
	progress_bar_1.max_value = Globals.MAX_PLAYER_HEALTH
	progress_bar_2.max_value = Globals.MAX_PLAYER_HEALTH

func _process(delta: float) -> void:
	progress_bar_1.value = float(Globals.player_data[Globals.PLAYER_1_ID].health)
	progress_bar_2.value = float(Globals.player_data[Globals.PLAYER_2_ID].health)
	$Player1Score.text = str(Globals.player_1_wins)
	$Player2Score.text = str(Globals.player_2_wins)
