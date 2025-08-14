class_name PauseLayer extends Node2D

signal resume_triggered

func _resume_game():
	resume_triggered.emit()
