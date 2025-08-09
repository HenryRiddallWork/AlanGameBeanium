extends Node2D

func _ready():
	Globals.pause_game.connect(paused)
	$Button.pressed.connect(_resume_game)
	

func paused():
	$".".visible = true
	
func _resume_game():
	Globals.resume()
	$".".visible = false
