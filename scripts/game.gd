extends Node

@onready var player_1_health: Label = $Player1Health
@onready var player_2_health: Label = $Player2Health


func _ready() -> void:
	player_1_health.text = str(Globals.player_data[Globals.PLAYER_1_ID].health)
	player_2_health.text = str(Globals.player_data[Globals.PLAYER_2_ID].health)
