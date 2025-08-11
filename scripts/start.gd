extends Node2D

@onready var startButton: Button = $StartButton


func _ready():
	Globals.start_game.connect(start)
	startButton.pressed.connect(_start_game)
	visible = true

func start():
	visible = true

func _start_game():
	Globals.start()
	visible = false
