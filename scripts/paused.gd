class_name PauseLayer extends Node2D

@onready var resume_button: Button = $ResumeButton

signal resume_triggered

func _ready():
	resume_button.pressed.connect(_resume_game)

func _resume_game():
	resume_triggered.emit()
