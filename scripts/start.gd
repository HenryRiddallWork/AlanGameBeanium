extends Node2D


func _ready():
	Globals.start_game.connect(start)
	$Button.pressed.connect(_start_game)
	$".".visible = true

func start():
	$".".visible = true
	
func _start_game():
	Globals.start()
	$".".visible = false
