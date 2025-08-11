extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_bar_2: ProgressBar = $ProgressBar2

func _ready() -> void:
	progress_bar.max_value = float(Globals.player_data[Globals.PLAYER_1_ID].health)
	progress_bar_2.max_value = float(Globals.player_data[Globals.PLAYER_2_ID].health)

func _process(delta: float) -> void:
	progress_bar.value = float(Globals.player_data[Globals.PLAYER_1_ID].health)
	progress_bar_2.value = float(Globals.player_data[Globals.PLAYER_2_ID].health)
