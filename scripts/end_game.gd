extends Node2D


func _ready():
	Globals.end_game.connect(end_game)

func end_game():
	visible = true
