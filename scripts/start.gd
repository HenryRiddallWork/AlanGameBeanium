class_name StartScreen extends Node2D

signal start_game_triggered

func _start_game():
	start_game_triggered.emit()
