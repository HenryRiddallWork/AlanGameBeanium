class_name StartScreen extends Node2D

@onready var startButton: Button = $StartButton

signal start_game_triggered

func _ready():
	startButton.pressed.connect(_start_game)

func _start_game():
	start_game_triggered.emit()
