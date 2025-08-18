class_name PauseLayer extends Control

signal resume_triggered

func _resume_game():
	resume_triggered.emit()
